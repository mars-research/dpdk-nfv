// Simplified #![no_std] Maglev implementation adapted from https://github.com/flier/rust-maglev
// Copyright 2020 Flier Lu, Zhaofeng Li
//
// Licensed under Apache License 2.0, see:
// https://github.com/flier/rust-maglev/blob/master/LICENSE
//
// Main changes from Flier's version:
// - Uses core::* imports instead of std::*
// - Uses a fixed table size (M) of 65537
// - Uses two different hashing algorithms for offset and skip
//   (See Section 3.4 in Eisenbud. Here we use FNV and XXHash like NetBricks.)
//
// This implementation is not built to be flexible. We do not implement a connection tracking
// table like Eisenbud.
//
// Quick example:
//
// let m = Maglev::new(&["blmntuu", "Aeimnpprr", "Aeeimnstz"]);
// println!("Selected backend: {}", &m.get("sanctioned"));

use alloc::vec::Vec;
use core::alloc::Layout;
use core::cell::RefCell;
use core::hash::{BuildHasher, BuildHasherDefault, Hash, Hasher};
use core::iter;
use core::default::Default;

use fnv::FnvHasher;
use twox_hash::XxHash;
//use wyhash::WyHash;

// type Hasher1 = BuildHasherDefault<wyhash::WyHash>;

#[cfg(feature = "use_hashbrown")]
type MaglevHashMap = hashbrown::HashMap<usize, usize>;

#[cfg(not(feature = "use_hashbrown"))]
type MaglevHashMap = sashstore_redleaf::cindexmap::CIndex<usize, usize>;

// For Maglev, we use a really stripped-down version of Indexmap
// use sashstore_redleaf::cindexmap::CIndex;

const TABLE_SIZE: usize = 65537;
const CACHE_SIZE: usize = (1 << 20) * 16;

static mut HIT_COUNT: usize = 0;
static mut HASHMAP_TOTAL: usize = 0;

/*
lut (consistent hashing), cache (connection tracking)

- receive the packet
- generate flowhash from 5-tuple
- lookup in cache
- if found in cache: just return
- if not found: (lut[hash] -> backend number) and insert into cache
*/

type Hasher1 = BuildHasherDefault<FnvHasher>;
type Hasher2 = BuildHasherDefault<XxHash>;

/// Maglev lookup table
pub struct Maglev<N> {
    pub nodes: Vec<N>,
    pub lookup: Vec<i8>,
    pub cache: RefCell<MaglevHashMap>,
}

impl<N: Hash + Eq> Maglev<N> {
    /// Creates a `Maglev` lookup table which will use the given hash builder to hash keys.
    pub fn new<I: IntoIterator<Item = N>>(nodes: I) -> Self {
        let nodes = nodes.into_iter().collect::<Vec<_>>();
        let lookup = Self::populate(&nodes);
        #[cfg(feature = "use_hashbrown")]
        let hashmap = MaglevHashMap::with_capacity_and_hasher(CACHE_SIZE, Default::default());
        #[cfg(not(feature = "use_hashbrown"))]
        let hashmap = MaglevHashMap::with_capacity(CACHE_SIZE);
        let cache = RefCell::new(hashmap);

        Maglev {
            nodes,
            lookup,
            cache,
        }
    }

    #[inline]
    fn hash_offset_skip<Q: Hash + Eq + ?Sized>(
        key: &Q,
        m: usize,
        h1f: &Hasher1,
        h2f: &Hasher2,
    ) -> (usize, usize) {
        let mut h1 = h1f.build_hasher();
        let mut h2 = h2f.build_hasher();

        // This replicates Netbricks' setup
        // https://github.com/NetSys/NetBricks/blob/71dfb94beaeac107d7cd359985f9bd66fd223e1b/test/maglev/src/nf.rs#L21
        key.hash(&mut h1);
        let skip = h1.finish() as usize % (m - 1) + 1;

        key.hash(&mut h2);
        let offset = h2.finish() as usize % m;

        (offset, skip)
    }

    fn populate(nodes: &[N]) -> Vec<i8> {
        let m = TABLE_SIZE;
        let n = nodes.len();

        let h1f: Hasher1 = Default::default();
        let h2f: Hasher2 = Default::default();

        let permutation: Vec<Vec<usize>> = nodes
            .iter()
            .map(|node| {
                let (offset, skip) = Self::hash_offset_skip(&node, m, &h1f, &h2f);
                (0..m).map(|i| (offset + i * skip) % m).collect()
            })
            .collect();

        let mut next: Vec<usize> = iter::repeat(0).take(n).collect();

        //let mut entry: Vec<i8> = iter::repeat(-1).take(m).collect();

        // align lookup table at cacheline boundary
        let mut entry = unsafe {
            let layout = Layout::from_size_align(m, 64)
                .map_err(|e| panic!("Layout error: {}", e))
                .unwrap();

            let buf = unsafe { alloc::alloc::alloc(layout) as *mut i8 };
            let mut v: Vec<i8> = unsafe { Vec::from_raw_parts(buf, m, m) };
            v.fill(-1);
            v
        };

        let mut j = 0;

        while j < m {
            for i in 0..n {
                let mut c = permutation[i][next[i]];

                while entry[c] >= 0 {
                    next[i] += 1;
                    c = permutation[i][next[i]];
                }

                entry[c] = i as i8;
                next[i] += 1;
                j += 1;

                if j == m {
                    break;
                }
            }
        }

        entry
    }

    #[inline]
    pub fn get_index<Q: ?Sized>(&self, key: &Q) -> usize
    where
        Q: Hash + Eq,
    {
        // NetBricks hashes the flow signature with FNV
        let h1f: Hasher1 = Default::default();
        let mut h1 = h1f.build_hasher();
        key.hash(&mut h1);
        let hash = h1.finish() as usize;

        self.get_index_from_hash(hash)
    }

    #[inline]
    pub fn get_index_from_hash(&self, hash: usize) -> usize {
        let mut cache = self.cache.borrow_mut();
        match cache.get(&hash) {
            Some(idx) => {
                // Use cached backend
                unsafe {
                    HIT_COUNT += 1;
                    HASHMAP_TOTAL += 1;
                }

                idx
            }
            None => {
                // Use lookup directly
                let x = self.lookup[hash % self.lookup.len()] as usize;
                cache.insert(hash, x);
                x
            }
        }
    }

    #[inline]
    pub fn get<Q: ?Sized>(&self, key: &Q) -> &N
    where
        Q: Hash + Eq,
    {
        &self.nodes[self.get_index(key)]
    }

    pub fn dump_stats(&self) {
        unsafe {
            println!("Hits: {}, total: {}", HIT_COUNT, HASHMAP_TOTAL);
        }
        //sashstore_redleaf::indexmap::print_stats();
    }
}

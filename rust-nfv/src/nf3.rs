use crate::packet::{Flow, Packet};

#[cfg(feature = "use_hashbrown")]
use core::hash::BuildHasherDefault;

#[cfg(feature = "use_hashbrown")]
type Hasher = BuildHasherDefault<fnv::FnvHasher>;
// type Hasher = BuildHasherDefault<wyhash::WyHash>;

#[cfg(feature = "use_hashbrown")]
type FlowHashSet = hashbrown::HashSet<Flow, Hasher>;

#[cfg(not(feature = "use_hashbrown"))]
type FlowHashSet = sashstore_redleaf::cindexmap::CIndex<Flow, ()>;

// From netbricks
#[derive(Clone)]
pub struct Acl {
    pub src_ip: Option<u32>,
    pub dst_ip: Option<u32>,
    pub src_port: Option<u16>,
    pub dst_port: Option<u16>,
    pub established: Option<bool>,
    // Related not done
    pub drop: bool,
}

impl Acl {
    pub fn matches(&self, flow: &Flow, connections: &FlowHashSet) -> bool {
        if (self.src_ip.is_none() || self.src_ip.unwrap() == (flow.src_ip))
            && (self.dst_ip.is_none() || self.dst_ip.unwrap() == (flow.dst_ip))
            && (self.src_port.is_none() || flow.src_port == self.src_port.unwrap())
            && (self.dst_port.is_none() || flow.dst_port == self.dst_port.unwrap())
        {
            if let Some(established) = self.established {
                let rev_flow = flow.reverse_flow();
                #[cfg(feature = "use_hashbrown")]
                return (connections.contains(flow) || connections.contains(&rev_flow)) == established;

                #[cfg(not(feature = "use_hashbrown"))]
                return connections.get(flow).is_some() || connections.get(&rev_flow).is_some() == established;
            } else {
                true
            }
        } else {
            false
        }
    }
}

pub struct Nf3Acl {
    flow_cache: FlowHashSet,
    acls: Vec<Acl>,
}

impl Nf3Acl {
    pub fn new(acls: Vec<Acl>) -> Self {
        #[cfg(feature = "use_hashbrown")]
        let flow_cache = FlowHashSet::with_hasher(Default::default());

        #[cfg(not(feature = "use_hashbrown"))]
        let flow_cache = FlowHashSet::new();

        Self {
            flow_cache,
            acls,
        }
    }
}

impl crate::nfv::NetworkFunction for Nf3Acl {
    fn process_frames(&mut self, packets: &mut [Packet]) {
        for pkt in packets.iter_mut() {
            let flow = pkt.get_flow();

            for acl in &self.acls {
                if acl.matches(&flow, &self.flow_cache) {
                    if !acl.drop {
                        #[cfg(feature = "use_hashbrown")]
                        self.flow_cache.insert(flow);

                        #[cfg(not(feature = "use_hashbrown"))]
                        self.flow_cache.insert(flow, ());
                    }
                    //return !acl.drop;
                }
            }
        }
    }
}

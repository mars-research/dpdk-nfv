#![feature(box_syntax)]
#![feature(bench_black_box)]
#![deny(unreachable_patterns)]

mod maglev;
mod nf1;
mod nf2;
mod nf3;
mod nf4;
mod nf5;
mod nfv;
mod packet;

extern crate alloc;

use packet::Packet;

const MAX_PKT_BURST: usize = 32;
const MAX_PKT_LEN: usize = 1514;
static mut PACKETS: Vec<Packet> = vec![];
static mut NFS: Vec<Box<dyn nfv::NetworkFunction>> = vec![];
static mut PACKET_OWNERS: Vec<Box<usize>> = vec![];

#[no_mangle]
pub unsafe extern "C" fn init_nfs(nfs: *const u8, len: u64) {
    let len = len as usize;
    PACKETS.reserve(MAX_PKT_BURST);

    // MAX_PKT_BURST + 1
    for _ in 0..=MAX_PKT_BURST {
        PACKET_OWNERS.push(Box::new(0));
    }

    for nf in std::slice::from_raw_parts(nfs, len) {
        NFS.push(match nf {
            1 => box nf1::Nf1DecrementTtl::new(),
            2 => box nf2::Nf2Nat::new(),
            3 => box nf3::Nf3Acl::new(vec![nf3::Acl {
                src_ip: None,
                dst_ip: None,
                src_port: None,
                dst_port: None,
                established: None,
                drop: false,
            }]),
            4 => box nf4::Nf4Maglev::new(),
            default => panic!("Unknown nf: {}", nf),
        })
    }
}

// NF1 + NF2 = 9M
// NF1 + NF3 = 14M
// NF1 + NF4 = 14M
// NF3 + NF4 = 9M
// NF1 = 14M
// NF2 = 9M
// NF3 = 14M
// NF4 = 14M

#[no_mangle]
pub unsafe extern "C" fn run_nfs(packets: *const *mut u8, num_pkt: u64) {
    PACKETS.drain(..);
    for packet in std::slice::from_raw_parts(packets, num_pkt as usize) {
        let mut packet = std::slice::from_raw_parts_mut(*packet, MAX_PKT_LEN);

        if let Some(pkt) = Packet::new(packet) {
            PACKETS.push(pkt);
        }
    }

    for nf in &mut NFS {
        simulate_rref_overhead(&PACKETS[..]);
        nf.process_frames(&mut PACKETS[..]);
        simulate_rref_overhead(&PACKETS[..]);
    }
}

#[no_mangle]
pub unsafe extern "C" fn report_nfs() {}

#[inline(always)]
fn simulate_rref_overhead(packets: &[Packet]) {
    unsafe {
        // Top-level RRef
        let ptr = &mut *PACKET_OWNERS[packets.len()] as *mut usize;
        core::ptr::write_volatile(ptr, packets.len());

        // Child RRefs
        for i in 0usize..packets.len() {
            let ptr = &mut *PACKET_OWNERS[i] as *mut usize;
            core::ptr::write_volatile(ptr, i);
        }
    }
}

#![feature(box_syntax)]

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

#[no_mangle]
pub unsafe extern "C" fn init_nfs() {
    PACKETS.reserve(MAX_PKT_BURST);
    NFS = vec![
        box nf1::Nf1DecrementTtl::new(),
        box nf2::Nf2OneWayNat::new(),
        box nf3::Nf3Acl::new(vec![nf3::Acl {
            src_ip: Some(0),
            dst_ip: None,
            src_port: None,
            dst_port: None,
            established: None,
            drop: false,
        }]),
        box nf4::Nf4Maglev::new(),
    ];
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
        nf.process_frames(&mut PACKETS[..]);
    }
}


#[no_mangle]
pub unsafe extern "C" fn report_nfs() {}
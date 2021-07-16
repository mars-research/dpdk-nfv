#![feature(box_syntax)]

mod nfv;
mod nf1;
mod nf2;
mod nf3;
mod nf4;
mod packettool;
mod maglev;

extern crate alloc;


use packettool::{ETH_HEADER_LEN, UDP_HEADER_LEN};

const MAX_PKT_BURST: usize = 32;
const MAX_PKT_LEN: usize = 1514;
static mut PACKETS: Vec<&'static mut [u8]> = vec![];
static mut NFS: Vec<Box<dyn nfv::NetworkFunction>> = vec![];


#[no_mangle]
pub unsafe extern "C" fn init_nfs() {
    PACKETS.reserve(MAX_PKT_BURST);
    NFS = vec![
        box nf1::Nf1DecrementTtl::new(), 
        box nf2::Nf2OneWayNat::new(),
        box nf3::Nf3Acl::new(vec![ 
            nf3::Acl {
                src_ip: Some(0),
                dst_ip: None,
                src_port: None,
                dst_port: None,
                established: None,
                drop: false,
            },
            ]), 
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
pub unsafe extern "C" fn run_nfs(packets: * const * mut u8, num_pkt: u64) {
    PACKETS.drain(..);
    for packet in std::slice::from_raw_parts(packets, num_pkt as usize) {
        let mut packet = std::slice::from_raw_parts_mut(*packet, MAX_PKT_LEN);
        if (packet[ETH_HEADER_LEN] >> 4) != 4 {
            // not ipv4
            continue;
        }
        
        // Caculate acutal packet len.
        let v4len = (packet[ETH_HEADER_LEN] & 0b1111) as usize * 4;
        let payload_len_upper = (packet[ETH_HEADER_LEN + v4len + 4] as usize);
        let payload_len_lower = packet[ETH_HEADER_LEN + v4len + 5] as usize;
        let payload_len = (payload_len_upper << 8) + (payload_len_lower);
        let total_len = ETH_HEADER_LEN + v4len + UDP_HEADER_LEN + payload_len;
        // dbg!(v4len, payload_len, total_len, payload_len_upper, payload_len_lower, (payload_len_upper << 8));
        PACKETS.push(&mut packet[..total_len]);
    }

    for nf in &mut NFS {
        nf.process_frames(&mut PACKETS[..]);
    }
}
use crate::packet::{Packet, IPV4_TTL_OFFSET};

pub struct Nf1DecrementTtl {}

impl Nf1DecrementTtl {
  pub fn new() -> Self {
    Self {}
  }
}

impl crate::nfv::NetworkFunction for Nf1DecrementTtl {
    fn process_frames(&mut self, packets: &mut[Packet]) {
        for pkt in packets.iter_mut() {
            let ip_header = pkt.ip_header();
            ip_header[IPV4_TTL_OFFSET] -= 1;
        }
    }
}

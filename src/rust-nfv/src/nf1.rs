

use crate::packettool::{ETH_HEADER_LEN, IPV4_TTL_OFFSET};

pub const PKT_TTL_OFFSET : usize = ETH_HEADER_LEN + IPV4_TTL_OFFSET;

pub struct Nf1DecrementTtl {

}

impl crate::nfv::NetworkFunction for Nf1DecrementTtl {
  fn process_frames(&mut self, packets: &mut[&mut[u8]]) {
    for pkt in packets.iter_mut() {
      let ttl = pkt[PKT_TTL_OFFSET] - 1;
      pkt[PKT_TTL_OFFSET] = ttl;
    }
  }
}
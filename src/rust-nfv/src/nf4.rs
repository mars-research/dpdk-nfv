use crate::packettool::{
  get_mut_udp_payload,
  Flow,
  ipv4_extract_flow,
  swap_mac,
  get_flowhash,
};
use crate::maglev::Maglev;

pub struct Nf4Maglev {
  maglev: Maglev<usize>,
}

impl Nf4Maglev {
  pub fn new() -> Self {
    Self {
      maglev: Maglev::new(0..3),
    }
  }
}

impl crate::nfv::NetworkFunction for Nf4Maglev {
  fn process_frames(&mut self, packets: &mut[&mut[u8]]) {
    for pkt in packets.iter_mut() {
      let backend = {
        if let Some(hash) = get_flowhash(pkt) {
            Some(self.maglev.get_index_from_hash(hash))
        } else {
            println!("flowhash failed");
            None
        }
      };

      if let Some(_) = backend {
          swap_mac(pkt);
      };
    }
  
  }
}
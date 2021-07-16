use fnv::FnvHasher;
use crate::packettool::{
    get_mut_udp_payload,
    calc_ipv4_checksum,
    Flow,
    IHL_TO_BYTE_FACTOR,
    ipv4_extract_flow,
};
use crate::packettool::ETH_HEADER_LEN;

use core::hash::BuildHasherDefault;

use std::collections::HashMap;

#[derive(Clone, Copy, Default)]
struct FlowUsed {
    pub flow: Flow,
    pub time: u64,
    pub used: bool,
}

const MIN_PORT: u16 = 1024;
const MAX_PORT: u16 = 65535;

type FnvHash = BuildHasherDefault<FnvHasher>;

pub struct Nf2OneWayNat {
  port_hash: HashMap::<Flow, Flow, FnvHash>,
  flow_vec: Vec<FlowUsed>,
  next_port: u16, 
}

impl Nf2OneWayNat {
  pub fn new() -> Self {
    Self {
      port_hash: HashMap::<Flow, Flow, FnvHash>::with_capacity_and_hasher(65536, Default::default()),
      flow_vec: (MIN_PORT..65535).map(|_| Default::default()).collect(),
      next_port: MIN_PORT,
    }
  }
}


impl crate::nfv::NetworkFunction for Nf2OneWayNat {
  fn process_frames(&mut self, packets: &mut[&mut[u8]]) {
    for pkt in packets.iter_mut() {
      // From netbricks
      unsafe {
        if let Some((_, _)) = get_mut_udp_payload(pkt) {
          let mut ipv4_hdr = &mut pkt[ETH_HEADER_LEN..];
          if let Some(flow) = ipv4_extract_flow(&ipv4_hdr) {
            let found = match self.port_hash.get(&flow) {
              Some(s) => {
                  s.ipv4_stamp_flow(&mut ipv4_hdr);
                    true
                  }
                  None => false,
                };
                if !found {
                    if self.next_port < MAX_PORT {
                        let assigned_port = self.next_port; //FIXME.
                        self.next_port += 1;
                        self.flow_vec[assigned_port as usize].flow = flow;
                self.flow_vec[assigned_port as usize].used = true;
                let mut outgoing_flow = flow.clone();
                //outgoing_flow.src_ip = ip;
                outgoing_flow.src_port = assigned_port;
                let rev_flow = outgoing_flow.reverse_flow();

                self.port_hash.insert(flow, outgoing_flow);
                self.port_hash.insert(rev_flow, flow.reverse_flow());

                outgoing_flow.ipv4_stamp_flow(&mut ipv4_hdr);
              }
            }
          }
        }
      }
    }
  
  }
}
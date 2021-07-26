use crate::packet::{Flow, Packet};

use core::hash::BuildHasherDefault;
use hashbrown::HashMap;

#[derive(Clone, Copy, Default)]
struct FlowUsed {
    pub flow: Flow,
    pub time: u64,
    pub used: bool,
}

const MIN_PORT: u16 = 1024;
const MAX_PORT: u16 = 65535;

// type Hasher = BuildHasherDefault<fnv::FnvHasher>;
type Hasher = BuildHasherDefault<wyhash::WyHash>;

pub struct Nf2OneWayNat {
    port_hash: HashMap<Flow, Flow, Hasher>,
    flow_vec: Vec<FlowUsed>,
    next_port: u16,
}

impl Nf2OneWayNat {
    pub fn new() -> Self {
        Self {
            port_hash: HashMap::<Flow, Flow, Hasher>::with_capacity_and_hasher(
                65536,
                Default::default(),
            ),
            flow_vec: (0..65535).map(|_| Default::default()).collect(),
            next_port: MIN_PORT,
        }
    }
}

impl crate::nfv::NetworkFunction for Nf2OneWayNat {
    fn process_frames(&mut self, packets: &mut [Packet]) {
        for pkt in packets.iter_mut() {
            // From netbricks
            let flow = pkt.get_flow();

            match self.port_hash.get(&flow) {
                Some(s) => {
                    pkt.set_flow(&s);
                }
                None => {
                    if self.next_port < MAX_PORT {
                        let assigned_port = self.next_port; //FIXME.
                        self.next_port += 1;
                        self.flow_vec[assigned_port as usize] = FlowUsed {
                            flow,
                            time: 0,
                            used: true,
                        };
                        let mut outgoing_flow = flow.clone();
                        //outgoing_flow.src_ip = ip;
                        outgoing_flow.src_port = assigned_port;
                        let rev_flow = outgoing_flow.reverse_flow();

                        self.port_hash.insert(flow, outgoing_flow);
                        self.port_hash.insert(rev_flow, flow.reverse_flow());

                        pkt.set_flow(&outgoing_flow);
                    }
                }
            };
        }
    }
}

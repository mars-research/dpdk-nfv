use crate::packet::{Flow, Packet};

const MIN_PORT: u16 = 1024;
const MAX_PORT: u16 = 65535;

const TABLE_SIZE: usize = (1 << 20) * 16;

static mut PACKET_IDX: usize = 0;

type FlowHashMap = cleanstore::cindexmap::CIndex;

pub struct Nf2Nat {
    port_hash: FlowHashMap,
    flow_vec: [Flow; 65536],
    next_port: u16,
}

impl Nf2Nat {
    pub fn new() -> Self {
        let port_hash = FlowHashMap::with_capacity(TABLE_SIZE);

        Self {
            port_hash,
            flow_vec: [Default::default(); 65536],
            next_port: MIN_PORT,
        }
    }
}

impl crate::nfv::NetworkFunction for Nf2Nat {
    fn process_frames(&mut self, packets: &mut [Packet]) {
        for pkt in packets.iter_mut() {
            // not a complete/correct implementation of the NAT, but has similar
            // overheads
            let flowhash = pkt.get_flowhash();
            /* For debugging
            let flowhash;
            unsafe {
                flowhash = PACKET_IDX;
                PACKET_IDX += 1;
                if PACKET_IDX >= (1 << 20) {
                    PACKET_IDX = 0;
                }
            }
            */

            match self.port_hash.get(flowhash) {
                (0, 0) => {
                    // new outgoing flow
                    if self.next_port < MAX_PORT {
                        let assigned_port = self.next_port;
                        self.next_port += 1;

                        let mut reverse_flow = pkt.get_flow().reverse_flow();
                        reverse_flow.dst_port = assigned_port;
                        let reverse_flowhash = reverse_flow.get_flowhash();
                        self.flow_vec[assigned_port as usize] = reverse_flow;

                        pkt.set_src_port(assigned_port);

                        self.port_hash.insert(flowhash, assigned_port as usize);
                        self.port_hash.insert(reverse_flowhash, 0);
                    }
                }
                (_flowhash, 0) => {
                    // reply packet with assigned port - stamp with reverse flow in flow_vec
                    let rev_flow = self.flow_vec[pkt.get_dst_port() as usize];
                    pkt.set_flow(&rev_flow);
                }
                (_flowhash, port) => {
                    // outgoing packet with assigned port - just change source port
                    pkt.set_src_port(port as u16);
                }
            };
        }
    }
}

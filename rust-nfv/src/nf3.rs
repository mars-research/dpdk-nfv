use crate::packet::{Flow, Packet};

type FlowHashSet = cleanstore::cindexmap::CIndex;

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
    pub fn matches(&self, flow: &Flow) -> bool {
        (self.src_ip.is_none() || self.src_ip.unwrap() == (flow.src_ip))
            && (self.dst_ip.is_none() || self.dst_ip.unwrap() == (flow.dst_ip))
            && (self.src_port.is_none() || flow.src_port == self.src_port.unwrap())
            && (self.dst_port.is_none() || flow.dst_port == self.dst_port.unwrap())
    }
}

pub struct Nf3Acl {
    flow_cache: FlowHashSet,
    acls: Vec<Acl>,
}

impl Nf3Acl {
    pub fn new(acls: Vec<Acl>) -> Self {
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
            let flowhash = pkt.get_flowhash();

            let mut matched = false;
            for acl in &self.acls {
                if acl.matches(&flow) {
                    matched = true;
                    if !acl.drop {
                        self.flow_cache.insert(flowhash, 0);
                    }
                }
            }

            if !matched {
                let reverse_flowhash = pkt.get_reverse_flowhash();

                let contains_flow = self.flow_cache.get(reverse_flowhash) != (0, 0);

                if contains_flow {
                    matched = true;
                }
            }

            std::hint::black_box(matched);
        }
    }
}

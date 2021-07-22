use crate::packet::{Flow, Packet};
use core::hash::BuildHasherDefault;
use hashbrown::HashSet;

// type Hasher = BuildHasherDefault<fnv::FnvHasher>;
type Hasher = BuildHasherDefault<wyhash::WyHash>;

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
    pub fn matches(&self, flow: &Flow, connections: &HashSet<Flow, Hasher>) -> bool {
        if (self.src_ip.is_none() || self.src_ip.unwrap() == (flow.src_ip))
            && (self.dst_ip.is_none() || self.dst_ip.unwrap() == (flow.dst_ip))
            && (self.src_port.is_none() || flow.src_port == self.src_port.unwrap())
            && (self.dst_port.is_none() || flow.dst_port == self.dst_port.unwrap())
        {
            if let Some(established) = self.established {
                let rev_flow = flow.reverse_flow();
                (connections.contains(flow) || connections.contains(&rev_flow)) == established
            } else {
                true
            }
        } else {
            false
        }
    }
}

pub struct Nf3Acl {
    flow_cache: HashSet<Flow, Hasher>,
    acls: Vec<Acl>,
}

impl Nf3Acl {
    pub fn new(acls: Vec<Acl>) -> Self {
        Self {
            flow_cache: HashSet::with_hasher(Default::default()),
            acls,
        }
    }
}

impl crate::nfv::NetworkFunction for Nf3Acl {
    fn process_frames(&mut self, packets: &mut [Packet]) {
        for pkt in packets.iter_mut() {
            let flow = pkt.get_flow();

            for acl in &self.acls {
                if acl.matches(&flow, &self.flow_cache) {
                    if !acl.drop {
                        self.flow_cache.insert(flow);
                    }
                    //return !acl.drop;
                }
            }
        }
    }
}

use crate::maglev::Maglev;
use crate::packet::Packet;

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
    fn process_frames(&mut self, packets: &mut [Packet]) {
        for pkt in packets.iter_mut() {
            let backend = {
                let hash = pkt.get_flowhash();
                Some(self.maglev.get_index_from_hash(hash))
            };

            if backend.is_some() {
                pkt.swap_mac();
            };
        }
    }
}

use crate::packet::{Packet, IPV4_TTL_OFFSET};

pub struct Nf5UpdateChecksum {}

impl Nf5UpdateChecksum {
    pub fn new() -> Self {
        Self {}
    }
}

impl crate::nfv::NetworkFunction for Nf5UpdateChecksum {
    fn process_frames(&mut self, packets: &mut [Packet]) {
        for pkt in packets.iter_mut() {
            if pkt.dirty() {
                pkt.recalculate_ip_checksum();
            }
        }
    }
}

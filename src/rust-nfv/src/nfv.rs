use super::packet::Packet;

pub trait NetworkFunction {
    fn process_frames(&mut self, packets: &mut [Packet]);
}

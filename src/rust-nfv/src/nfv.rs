
pub trait NetworkFunction {
  fn process_frames(&mut self, packets: &mut[&mut[u8]]);
}

pub struct Packet {
  bytes: &'static mut [u8],
  v4len: u16,
}
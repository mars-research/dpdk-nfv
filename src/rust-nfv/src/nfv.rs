
pub trait NetworkFunction {
  fn process_frames(&mut self, packets: &mut[&mut[u8]]);
}
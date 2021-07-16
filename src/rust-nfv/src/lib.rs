
const MAX_PKT_BURST: usize = 32;
const MAX_PKT_LEN: usize = 1514;
static mut PACKETS: Vec<&'static [u8]> = vec![];


#[no_mangle]
pub unsafe extern "C" fn init_nfs() {
    PACKETS.reserve(MAX_PKT_BURST);
}

#[no_mangle]
pub unsafe extern "C" fn run_nfs(packets: * const * const u8, num_pkt: u64) {
    PACKETS.drain(..);
    for packet in std::slice::from_raw_parts(packets, num_pkt as usize) {
        PACKETS.push(std::slice::from_raw_parts(*packet, MAX_PKT_LEN))
    } 
}
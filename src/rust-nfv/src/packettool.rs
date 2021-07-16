use core::hash::{BuildHasher, BuildHasherDefault, Hash, Hasher};

use fnv::FnvHasher;
use byteorder::{BigEndian, ByteOrder};

pub const ETH_HEADER_LEN: usize = 14;
pub const UDP_HEADER_LEN: usize = 8;

// https://en.wikipedia.org/wiki/IPv4
pub const IPV4_PROTO_OFFSET: usize = 9;
pub const IPV4_TTL_OFFSET: usize = 8;
pub const IPV4_LENGTH_OFFSET: usize = 2;
pub const IPV4_CHECKSUM_OFFSET: usize = 10;
pub const IPV4_SRCDST_OFFSET: usize = 12;
pub const IPV4_SRCDST_LEN: usize = 8;

pub const UDP_LENGTH_OFFSET: usize = 4;
pub const UDP_CHECKSUM_OFFSET: usize = 6;
pub const IHL_TO_BYTE_FACTOR: usize = 4; // IHL is in terms of number of 32-bit words.

pub fn swap_mac(frame: &mut [u8]) {
    for i in 0..6 {
        frame.swap(i, 6 + i);
    }
}

pub fn fix_ip_length(frame: &mut [u8]) {
    let length = frame.len() - ETH_HEADER_LEN;
    frame[ETH_HEADER_LEN + IPV4_LENGTH_OFFSET] = (length >> 8) as u8;
    frame[ETH_HEADER_LEN + IPV4_LENGTH_OFFSET + 1] = length as u8;
}

pub fn fix_ip_checksum(frame: &mut [u8]) {
    // Length of IPv4 header
    let v4len = (frame[ETH_HEADER_LEN] & 0b1111) as usize * 4;

    let checksum = calc_ipv4_checksum(&frame[ETH_HEADER_LEN..(ETH_HEADER_LEN + v4len)]);

    // Calculated checksum is little-endian; checksum field is big-endian
    frame[ETH_HEADER_LEN + IPV4_CHECKSUM_OFFSET] = (checksum >> 8) as u8;
    frame[ETH_HEADER_LEN + IPV4_CHECKSUM_OFFSET + 1] = (checksum & 0xff) as u8;
}

pub fn fix_udp_length(frame: &mut [u8]) {
    // Length of IPv4 header
    let v4len = (frame[ETH_HEADER_LEN] & 0b1111) as usize * 4;

    let length = frame.len() - ETH_HEADER_LEN - v4len;

    frame[ETH_HEADER_LEN + v4len + UDP_LENGTH_OFFSET] = (length >> 8) as u8;
    frame[ETH_HEADER_LEN + v4len + UDP_LENGTH_OFFSET + 1] = length as u8;
}

pub fn fix_udp_checksum(frame: &mut [u8]) {
    // Length of IPv4 header
    let v4len = (frame[ETH_HEADER_LEN] & 0b1111) as usize * 4;

    frame[ETH_HEADER_LEN + v4len + UDP_CHECKSUM_OFFSET] = 0;
    frame[ETH_HEADER_LEN + v4len + UDP_CHECKSUM_OFFSET + 1] = 0;
}

#[inline(always)]
fn fnv_a(data: &[u8], state: &mut u64) {
    for i in 0..data.len() {
        *state = (*state).wrapping_mul(0x100_0000_01b3);
        *state ^= data[i] as u64;
    }
}

pub fn get_flowhash(frame: &[u8]) -> Option<usize> {
    // Ugly but fast (supposedly)
    // let h1f: BuildHasherDefault<FnvHasher> = Default::default();
    // let mut h1 = h1f.build_hasher();
    let mut state: u64 = 0xcbf29ce4_8422_2325;

    /*
    if frame[ETH_HEADER_LEN] >> 4 != 4 {
        // This shitty implementation can only handle IPv4 :(
        return None
    }
    */

    // Length of IPv4 header
    let v4len = (frame[ETH_HEADER_LEN] & 0b1111) as usize * 4;

    // Hash source/destination IP addresses
    fnv_a(
        &frame[(ETH_HEADER_LEN + IPV4_SRCDST_OFFSET)
            ..(ETH_HEADER_LEN + IPV4_SRCDST_OFFSET + IPV4_SRCDST_LEN)],
        &mut state,
    );
    // frame[(ETH_HEADER_LEN + IPV4_SRCDST_OFFSET)..(ETH_HEADER_LEN + IPV4_SRCDST_OFFSET + IPV4_SRCDST_LEN)].hash(&mut h1);

    // Hash IP protocol number
    let proto = frame[ETH_HEADER_LEN + IPV4_PROTO_OFFSET];
    /*
    if proto != 6 && proto != 17 {
        // This shitty implementation can only handle TCP and UDP
        return None;
    }
    */
    state = state.wrapping_mul(0x100000001b3);
    state ^= u64::from(proto);

    // proto.hash(&mut h1);

    // Hash source/destination port
    fnv_a(
        &frame[(ETH_HEADER_LEN + v4len)..(ETH_HEADER_LEN + v4len + 4)],
        &mut state,
    );
    // frame[(ETH_HEADER_LEN + v4len)..(ETH_HEADER_LEN + v4len + 4)].hash(&mut h1);

    // Some(h1.finish() as usize)
    Some(state as usize)
}

pub fn get_mut_udp_payload(frame: &mut [u8]) -> Option<(usize, &mut [u8])> {
    if frame[ETH_HEADER_LEN] >> 4 != 4 {
        // This shitty implementation can only handle IPv4 :(
        return None;
    }

    // Length of IPv4 header
    let v4len = (frame[ETH_HEADER_LEN] & 0b1111) as usize * 4;

    // Check IP protocol number
    let proto = frame[ETH_HEADER_LEN + IPV4_PROTO_OFFSET];
    if proto != 17 {
        // UDP only sorry
        return None;
    }

    Some((
        ETH_HEADER_LEN + v4len + UDP_HEADER_LEN,
        &mut frame[(ETH_HEADER_LEN + v4len + UDP_HEADER_LEN)..],
    ))
}

pub fn swap_udp_ips(frame: &mut [u8]) {
    // Swaps both the IPs in the IPv4 header and the ports in the UDP header
    let v4len = (frame[ETH_HEADER_LEN] & 0b1111) as usize * 4;

    // UDP ports
    for i in 0..2 {
        frame.swap(ETH_HEADER_LEN + v4len + i, ETH_HEADER_LEN + v4len + 2 + i);
    }

    // IP addresses
    for i in 0..4 {
        frame.swap(ETH_HEADER_LEN + 12 + i, ETH_HEADER_LEN + 12 + 4 + i);
    }
}

pub fn calc_ipv4_checksum(ipv4_header: &[u8]) -> u16 {
    assert!(ipv4_header.len() % 2 == 0);
    let mut checksum = 0;
    for i in 0..ipv4_header.len() / 2 {
        if i == 5 {
            // Assume checksum field is set to 0
            continue;
        }
        checksum += (u32::from(ipv4_header[i * 2]) << 8) + u32::from(ipv4_header[i * 2 + 1]);
        if checksum > 0xffff {
            checksum = (checksum & 0xffff) + 1;
        }
    }
    !(checksum as u16)
}

#[derive(Debug, Copy, Clone, Default, PartialEq, Eq, Hash, Ord, PartialOrd)]
#[repr(C, packed)]
pub struct Flow {
    pub src_ip: u32,
    pub dst_ip: u32,
    pub src_port: u16,
    pub dst_port: u16,
    pub proto: u8,
}

impl Flow {
    pub fn ipv4_stamp_flow(&self, bytes: &mut [u8]) {
        let port_start = (bytes[0] & 0xf) as usize * IHL_TO_BYTE_FACTOR;
        BigEndian::write_u32(&mut bytes[12..16], self.src_ip);
        BigEndian::write_u32(&mut bytes[16..20], self.dst_ip);
        BigEndian::write_u16(&mut bytes[(port_start)..(port_start + 2)], self.src_port);
        BigEndian::write_u16(
            &mut bytes[(port_start + 2)..(port_start + 4)],
            self.dst_port,
        );
        BigEndian::write_u16(&mut bytes[10..12], 0);
        let csum = calc_ipv4_checksum(bytes);
        BigEndian::write_u16(&mut bytes[10..12], csum);
        // FIXME: l4 cksum
    }

    #[inline]
    pub fn reverse_flow(&self) -> Flow {
        Flow {
            src_ip: self.dst_ip,
            dst_ip: self.src_ip,
            src_port: self.dst_port,
            dst_port: self.src_port,
            proto: self.proto,
        }
    }
}

pub fn ipv4_extract_flow(bytes: &[u8]) -> Option<Flow> {
    let port_start = (bytes[0] & 0xf) as usize * IHL_TO_BYTE_FACTOR;
    Some(Flow {
        proto: bytes[9],
        src_ip: BigEndian::read_u32(&bytes[12..16]),
        dst_ip: BigEndian::read_u32(&bytes[16..20]),
        src_port: BigEndian::read_u16(&bytes[(port_start)..(port_start + 2)]),
        dst_port: BigEndian::read_u16(&bytes[(port_start + 2)..(port_start + 4)]),
    })
}

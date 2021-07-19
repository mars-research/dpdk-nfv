use core::hash::{Hash, Hasher};

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

pub struct Packet {
    frame: &'static mut [u8],
}

impl Packet {
    pub fn new(frame: &'static mut [u8]) -> Option<Self> {
        // We only deal with IPv4 UDP packets
        let ip_version = frame[ETH_HEADER_LEN] >> 4;
        let ip_proto = frame[ETH_HEADER_LEN + IPV4_PROTO_OFFSET];

        if ip_version == 4 || ip_proto == 17 {
            Some(Self {
                frame,
            })
        } else {
            None
        }
    }

    pub fn ip_header_len(&self) -> usize {
        (self.frame[ETH_HEADER_LEN] & 0b1111) as usize * IHL_TO_BYTE_FACTOR
    }

    pub fn ip_len(&self) -> usize {
        BigEndian::read_u16(&self.frame[ETH_HEADER_LEN + 2..ETH_HEADER_LEN + 3]) as usize
    }

    pub fn eth_len(&self) -> usize {
        ETH_HEADER_LEN + self.ip_len()
    }

    pub fn ip_header(&mut self) -> &mut [u8] {
        let ip_header_len = self.ip_header_len();
        &mut self.frame[ETH_HEADER_LEN..ETH_HEADER_LEN + ip_header_len]
    }

    pub fn ip_payload(&mut self) -> &mut [u8] {
        let header_len = self.ip_header_len();
        let ip_len = self.ip_len();
        &mut self.frame[ETH_HEADER_LEN + header_len..ETH_HEADER_LEN + ip_len]
    }

    pub fn get_flow(&mut self) -> Flow {
        let (proto, src_ip, dst_ip) = {
            let ip_header = self.ip_header();
            (
                ip_header[IPV4_PROTO_OFFSET],
                BigEndian::read_u32(&ip_header[12..16]),
                BigEndian::read_u32(&ip_header[16..20]),
            )
        };
        let (src_port, dst_port) = {
            let ip_payload = self.ip_payload();
            (
                BigEndian::read_u16(&ip_payload[0..2]),
                BigEndian::read_u16(&ip_payload[2..4]),
            )
        };

        Flow {
            proto, src_ip, dst_ip,
            src_port, dst_port,
        }
    }

    pub fn set_flow(&mut self, flow: &Flow) {
        {
            let ip_header = self.ip_header();

            BigEndian::write_u32(&mut ip_header[12..16], flow.src_ip);
            BigEndian::write_u32(&mut ip_header[16..20], flow.dst_ip);
        }

        {
            let ip_payload = self.ip_payload();
            BigEndian::write_u16(&mut ip_payload[0..2], flow.src_port);
            BigEndian::write_u16(
                &mut ip_payload[2..4],
                flow.dst_port,
            );
        }
    }

    pub fn recalculate_ip_checksum(&mut self) {
        let mut checksum = 0;
        let ip_header_len = self.ip_header_len();
        let ip_header = self.ip_header();

        BigEndian::write_u16(&mut ip_header[10..12], 0);

        for i in 0..ip_header_len / 2 {
            if i == 5 {
                // Assume checksum field is set to 0
                continue;
            }
            checksum += (u32::from(ip_header[i * 2]) << 8) + u32::from(ip_header[i * 2 + 1]);
            if checksum > 0xffff {
                checksum = (checksum & 0xffff) + 1;
            }
        }
        let checksum = !(checksum as u16);

        ip_header[IPV4_CHECKSUM_OFFSET] = (checksum >> 8) as u8;
        ip_header[IPV4_CHECKSUM_OFFSET + 1] = (checksum & 0xff) as u8;
    }

    pub fn swap_mac(&mut self) {
        for i in 0..6 {
            self.frame.swap(i, 6 + i);
        }
    }

    pub fn get_flowhash(&self) -> usize {
        // Ugly but fast (supposedly)
        let mut state: u64 = 0xcbf29ce4_8422_2325;

        // Length of IPv4 header
        let v4len = (self.frame[ETH_HEADER_LEN] & 0b1111) as usize * 4;

        // Hash source/destination IP addresses
        fnv_a(
            &self.frame[(ETH_HEADER_LEN + IPV4_SRCDST_OFFSET)
                ..(ETH_HEADER_LEN + IPV4_SRCDST_OFFSET + IPV4_SRCDST_LEN)],
            &mut state,
        );

        // Hash IP protocol number
        let proto = self.frame[ETH_HEADER_LEN + IPV4_PROTO_OFFSET];
        state = state.wrapping_mul(0x100000001b3);
        state ^= u64::from(proto);

        // Hash source/destination port
        fnv_a(
            &self.frame[(ETH_HEADER_LEN + v4len)..(ETH_HEADER_LEN + v4len + 4)],
            &mut state,
        );

        state as usize
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

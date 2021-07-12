#include "packettool.hpp"

Flow Flow::reverse_flow() const {
  return Flow(this->dst_ip, this->src_ip, this->dst_port, this->src_port,
              this->proto);
}

void Flow::ipv4_stamp_flow(rte_ipv4_hdr *ipv4_hdr, rte_udp_hdr *udp_hdr) const {
  // Update the packet with the NATed flow's IP and port.
  ipv4_hdr->src_addr = this->src_ip;
  ipv4_hdr->dst_addr = this->dst_ip;
  udp_hdr->src_port = this->src_port;
  udp_hdr->dst_port = this->dst_port;

  // Update IPv4 and l4 checksum.
  // Note that our Rust implementation doesn't do that.
  rte_ipv4_udptcp_cksum(ipv4_hdr, udp_hdr);
}

bool operator==(const Flow &lhs, const Flow &rhs) {
  return lhs.src_ip == rhs.src_ip && lhs.dst_ip == rhs.dst_ip &&
         lhs.src_port == rhs.src_port && lhs.dst_port == rhs.dst_port &&
         lhs.proto == rhs.proto;
}

bool operator==(const FlowUsed &lhs, const FlowUsed &rhs) {
  return lhs.flow == rhs.flow && lhs.time == rhs.time && lhs.used == rhs.used;
}
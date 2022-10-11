#include "packettool.hpp"

#include <optional>
#include <tuple>

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
  // BTW we enabled offload so this is disabled.
  // Note that our Rust implementation doesn't do that.
  // ipv4_hdr->hdr_checksum = rte_cpu_to_be_16(rte_ipv4_udptcp_cksum(ipv4_hdr,
  // udp_hdr));
}

bool operator==(const Flow &lhs, const Flow &rhs) {
  return lhs.src_ip == rhs.src_ip && lhs.dst_ip == rhs.dst_ip &&
         lhs.src_port == rhs.src_port && lhs.dst_port == rhs.dst_port &&
         lhs.proto == rhs.proto;
}

bool operator==(const FlowUsed &lhs, const FlowUsed &rhs) {
  return lhs.flow == rhs.flow && lhs.time == rhs.time && lhs.used == rhs.used;
}

rte_ipv4_hdr *get_ipv4_hdr(const rte_ether_hdr *eth_hdr) {
  // Get IPv4 header.
  if (eth_hdr->ether_type != rte_cpu_to_be_16(RTE_ETHER_TYPE_IPV4)) {
    return nullptr;
  }
  return (struct rte_ipv4_hdr *)((uint8_t *)eth_hdr +
                                 sizeof(struct rte_ether_hdr));
}

std::optional<std::tuple<rte_ipv4_hdr *, rte_udp_hdr *>> get_packet_headers(
    rte_ether_hdr *eth_hdr) {
  // Get IPv4 header.
  rte_ipv4_hdr *ipv4_hdr = get_ipv4_hdr(eth_hdr);
  if (ipv4_hdr == nullptr) {
    return {};
  }

  // Get UDP header.
  if (ipv4_hdr->next_proto_id != IPPROTO_UDP) {
    return {};
  }
  size_t ip_hdr_offset =
      (ipv4_hdr->version_ihl & RTE_IPV4_HDR_IHL_MASK) * RTE_IPV4_IHL_MULTIPLIER;
  rte_udp_hdr *udp_hdr =
      (struct rte_udp_hdr *)((uint8_t *)ipv4_hdr + ip_hdr_offset);

  return {{ipv4_hdr, udp_hdr}};
}

void swap_mac(rte_mbuf *m) {
  rte_ether_hdr *eth_hdr = (rte_ether_hdr*)m->buf_addr;
  // rte_ether_hdr *eth_hdr = rte_pktmbuf_mtod(m, struct rte_ether_hdr *);
  swap_mac(eth_hdr);
}

void swap_mac(rte_ether_hdr *eth_hdr) {
  std::swap(eth_hdr->s_addr, eth_hdr->d_addr);
}

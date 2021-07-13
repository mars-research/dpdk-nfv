#include <optional>

#include <absl/container/flat_hash_set.h>
#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>

#include "packettool.hpp"

extern "C" void nf3_init() {}

struct Acl {
  std::optional<rte_be32_t> src_ip;
  std::optional<rte_be32_t> dst_ip;
  std::optional<rte_be16_t> src_port;
  std::optional<rte_be16_t> dst_port;
  std::optional<bool> established;
  // Related not done
  bool drop;

  bool matches(const Flow &flow, const absl::flat_hash_set<Flow> &connections) const {
    const bool src_ip_matched =
        !this->src_ip.has_value() || this->src_ip.value() == flow.src_ip;
    const bool dst_ip_matched =
        !this->dst_ip.has_value() || this->dst_ip.value() == flow.dst_ip;
    const bool src_port_matched =
        !this->src_port.has_value() || this->src_port.value() == flow.src_port;
    const bool dst_port_matched =
        !this->dst_port.has_value() || this->dst_port.value() == flow.dst_port;

    if (src_ip_matched && dst_ip_matched && src_port_matched &&
        dst_port_matched) {
      if (this->established.has_value()) {
        // If the flow is already established by the destination, we will let it
        // pass if `established` is set to true.
        const Flow reversed_flow = flow.reverse_flow();
        return connections.contains(flow) ||
               connections.contains(reversed_flow) == established;
      }
      return true;
    }
    return false;
  }
};

static absl::flat_hash_set<Flow> FLOW_CACHE(1 << 16);
static std::vector<Acl> ACLS = {Acl{
  src_ip : 0,
  dst_ip : {},
  src_port : {},
  dst_port : {},
  established : {},
  drop : false,
}};

extern "C" void nf3_acl(rte_mbuf *m) {
  // Get ethernet header.
  rte_ether_hdr *eth_hdr = rte_pktmbuf_mtod(m, struct rte_ether_hdr *);

  // Get IPv4 header.
  if (eth_hdr->ether_type != rte_cpu_to_be_16(RTE_ETHER_TYPE_IPV4)) {
    return;
  }
  struct rte_ipv4_hdr *ipv4_hdr =
      (struct rte_ipv4_hdr *)((uint8_t *)eth_hdr +
                              sizeof(struct rte_ether_hdr));

  // Get UDP header.
  if (ipv4_hdr->next_proto_id != IPPROTO_UDP) {
    return;
  }
  size_t ip_hdr_offset =
      (ipv4_hdr->version_ihl & RTE_IPV4_HDR_IHL_MASK) * RTE_IPV4_IHL_MULTIPLIER;
  rte_udp_hdr *udp_hdr =
      (struct rte_udp_hdr *)((uint8_t *)ipv4_hdr + ip_hdr_offset);

    // Extract flow.
  const Flow flow(ipv4_hdr->src_addr, ipv4_hdr->dst_addr, udp_hdr->src_port,
                  udp_hdr->dst_port, eth_hdr->ether_type);

    for (const auto& acl : ACLS) {
        if (acl.matches(flow, FLOW_CACHE)) {
            if (!acl.drop) {
                FLOW_CACHE.insert(flow);
            }
            //return !acl.drop;
        }
    }
    //return false;
}
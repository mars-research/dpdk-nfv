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

  bool matches(const Flow &flow,
               const absl::flat_hash_set<Flow> &connections) const {
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

extern "C" void _nf3_acl(rte_mbuf *m) {
  // Get packet header.
  const auto headers = get_packet_headers(m);
  if (!(headers)) {
    return;
  }
  auto [eth_hdr, ipv4_hdr, udp_hdr] = headers.value();

  // Extract flow.
  const Flow flow(eth_hdr, ipv4_hdr, udp_hdr);

  for (const auto &acl : ACLS) {
    if (acl.matches(flow, FLOW_CACHE)) {
      if (!acl.drop) {
        FLOW_CACHE.insert(flow);
      }
      // return !acl.drop;
    }
  }
  // return false;
}
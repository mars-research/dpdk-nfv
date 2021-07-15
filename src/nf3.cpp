#include "nf3.hpp"

#include <optional>

#include <absl/container/flat_hash_set.h>
#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>

#include "packettool.hpp"

extern "C" void nf3_init() {}

bool Acl::matches(const Flow &flow,
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

NF3Acl::NF3Acl(const std::vector<Acl> acls)
    : flow_cache_(1 << 16), acls_(acls) {}

void NF3Acl::_process_frames(const std::span<rte_mbuf *> packets) {
  for (auto &&packet : packets) {
    // Get packet header.
    const auto headers = get_packet_headers(packet);
    if (!(headers)) {
      return;
    }
    auto [eth_hdr, ipv4_hdr, udp_hdr] = headers.value();

    // Extract flow.
    const Flow flow(eth_hdr, ipv4_hdr, udp_hdr);

    for (const auto &acl : this->acls_) {
      if (acl.matches(flow, this->flow_cache_)) {
        if (!acl.drop) {
          this->flow_cache_.insert(flow);
        }
        // return !acl.drop;
      }
    }
    // return false;
  }
}

#include "nf2.hpp"

#include <absl/container/flat_hash_map.h>
#include <absl/hash/hash.h>
#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>

#include <cstdint>

#include "nfv.hpp"
#include "packettool.hpp"

NF2OneWayNat::NF2OneWayNat() : port_hash_(MAX_SIZE), flow_vec_(MAX_SIZE) {}

void NF2OneWayNat::_process_frames(const std::span<rte_ether_hdr *> packets) {
  for (auto &&eth_hdr : packets) {
    // Get packet header.
    const auto headers = get_packet_headers(eth_hdr);
    if (!(headers)) {
      return;
    }
    auto [ipv4_hdr, udp_hdr] = headers.value();

    // Extract flow.
    const Flow flow(eth_hdr, ipv4_hdr, udp_hdr);

    // Check if the flow is already NATed.
    const auto iter = this->port_hash_.find(flow);
    if (iter != this->port_hash_.end()) {
      // Stamp the pack with the outgoing flow.
      const Flow &outgoing_flow = iter->second;
      outgoing_flow.ipv4_stamp_flow(ipv4_hdr, udp_hdr);
    } else if (this->next_port_ < MAX_PORT) {
      // Allocate a new port.
      const auto assigned_port = this->next_port_;
      this->next_port_++;

      // Update flow_vec
      this->flow_vec_[assigned_port] = {flow, 0, true};

      // Create a new outgoing flow.
      Flow outgoing_flow = flow;
      outgoing_flow.src_port = assigned_port;

      // Update flow mapping.
      this->port_hash_.try_emplace(flow, outgoing_flow);
      this->port_hash_.try_emplace(outgoing_flow.reverse_flow(),
                                   flow.reverse_flow());

      // Stamp the pack with the outgoing flow.
      outgoing_flow.ipv4_stamp_flow(ipv4_hdr, udp_hdr);
    }
  }
}
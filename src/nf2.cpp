#include <absl/container/flat_hash_map.h>
#include <absl/hash/hash.h>
#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>

#include <cstdint>

#include "nfv.hpp"
#include "packettool.hpp"

// TODO: use FNV?
static size_t MAX_SIZE = 1 << 16;
static absl::flat_hash_map<Flow, Flow, absl::Hash<Flow>> PORT_HASH;
static std::vector<FlowUsed> FLOW_VEC(MAX_SIZE);
const uint16_t MIN_PORT = 1024;
const uint16_t MAX_PORT = 65535;
static uint16_t NEXT_PORT = MIN_PORT;

extern "C" void nf2_init() { PORT_HASH.reserve(1 << 16); }

extern "C" void _nf2_one_way_nat(rte_mbuf *m) {
  // Get packet header.
  const auto headers = get_packet_headers(m);
  if (!(headers)) {
    return;
  }
  auto [eth_hdr, ipv4_hdr, udp_hdr] = headers.value();

  // Extract flow.
  const Flow flow(eth_hdr, ipv4_hdr, udp_hdr);

  // Check if the flow is already NATed.
  const auto iter = PORT_HASH.find(flow);
  if (iter != PORT_HASH.end()) {
    // Stamp the pack with the outgoing flow.
    const Flow &outgoing_flow = iter->second;
    outgoing_flow.ipv4_stamp_flow(ipv4_hdr, udp_hdr);
  } else if (NEXT_PORT < MAX_PORT) {
    // Allocate a new port.
    const auto assigned_port = NEXT_PORT;
    NEXT_PORT++;

    FLOW_VEC[assigned_port].flow = flow;
    FLOW_VEC[assigned_port].used = true;

    // Create a new outgoing flow.
    Flow outgoing_flow = flow;
    outgoing_flow.src_port = assigned_port;

    // Update flow mapping.
    PORT_HASH.try_emplace(flow, outgoing_flow);
    PORT_HASH.try_emplace(outgoing_flow.reverse_flow(), flow.reverse_flow());

    // Stamp the pack with the outgoing flow.
    outgoing_flow.ipv4_stamp_flow(ipv4_hdr, udp_hdr);
  }
}
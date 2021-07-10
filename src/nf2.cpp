#include <absl/container/flat_hash_map.h>
#include <absl/hash/hash.h>
#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>

#include <cstdint>

#include "nfv.hpp"

struct Flow {
  rte_be32_t src_ip;
  rte_be32_t dst_ip;
  rte_be16_t src_port;
  rte_be16_t dst_port;
  rte_be16_t proto;

  Flow(rte_be32_t src_ip, rte_be32_t dst_ip, rte_be16_t src_port,
       rte_be16_t dst_port, rte_be16_t proto)
      : src_ip(src_ip),
        dst_ip(dst_ip),
        src_port(src_port),
        dst_port(dst_port),
        proto(proto) {}

  Flow reverse_flow() const {
    return Flow(this->dst_ip, this->src_ip, this->dst_port, this->src_port, this->proto);
  }

  // Update the packet with the NATed flow's IP and port and update the checksum.
  void ipv4_stamp_flow(rte_ipv4_hdr *ipv4_hdr, rte_udp_hdr *udp_hdr) const {
    // Update the packet with the NATed flow's IP and port.
    ipv4_hdr->src_addr = this->src_ip;
    ipv4_hdr->dst_addr = this->dst_ip;
    udp_hdr->src_port = this->src_port;
    udp_hdr->dst_port = this->dst_port;

    // Update IPv4 and l4 checksum.
    // Note that our Rust implementation doesn't do that.
    rte_ipv4_udptcp_cksum(ipv4_hdr, udp_hdr);
  }

  friend bool operator==(const Flow &lhs, const Flow &rhs);
};

bool operator==(const Flow &lhs, const Flow &rhs) {
  return lhs.src_ip == rhs.src_ip && lhs.dst_ip == rhs.dst_ip &&
         lhs.src_port == rhs.src_port && lhs.dst_port == rhs.dst_port &&
         lhs.proto == rhs.proto;
}

template <typename H>
H AbslHashValue(H h, const Flow &f) {
  return H::combine(std::move(h), f.src_ip, f.dst_ip, f.src_port, f.dst_port,
                    f.proto);
}

struct FlowUsed {
  Flow flow;
  uint64_t time;
  bool used;

  FlowUsed(Flow flow, uint64_t time, bool used)
      : flow(flow), time(time), used(used) {}

  friend bool operator==(const FlowUsed &lhs, const FlowUsed &rhs);
};

bool operator==(const FlowUsed &lhs, const FlowUsed &rhs) {
  return lhs.flow == rhs.flow && lhs.time == rhs.time && lhs.used == rhs.used;
}

template <typename H>
H AbslHashValue(H h, const FlowUsed &f) {
  return H::combine(std::move(h), f.flow, f.time, f.used);
}

// TODO: use FNV?
static absl::flat_hash_map<Flow, Flow, absl::Hash<Flow>> PORT_HASH;
static std::vector<FlowUsed> FLOW_VEC;
const uint16_t MIN_PORT = 1024;
const uint16_t MAX_PORT = 65535;
static uint16_t NEXT_PORT = MIN_PORT;

extern "C" void nf2_init() {
  PORT_HASH.reserve(1 << 16);
  FLOW_VEC.reserve(1 << 16);
}

extern "C" void nf2_one_way_nat(rte_mbuf *m) {
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
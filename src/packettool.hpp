#include <cstdint>
#include <utility>

#include <rte_byteorder.h>
#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>

struct Flow {
  rte_be32_t src_ip;
  rte_be32_t dst_ip;
  rte_be16_t src_port;
  rte_be16_t dst_port;
  rte_be16_t proto;

  Flow() : src_ip(0), dst_ip(0), src_port(0), dst_port(0), proto(0) {}

  Flow(rte_be32_t src_ip, rte_be32_t dst_ip, rte_be16_t src_port,
       rte_be16_t dst_port, rte_be16_t proto)
      : src_ip(src_ip), dst_ip(dst_ip), src_port(src_port), dst_port(dst_port),
        proto(proto) {}

  Flow reverse_flow() const;

  // Update the packet with the NATed flow's IP and port and update the
  // checksum.
  void ipv4_stamp_flow(rte_ipv4_hdr *ipv4_hdr, rte_udp_hdr *udp_hdr) const;

  friend bool operator==(const Flow &lhs, const Flow &rhs);
};

bool operator==(const Flow &lhs, const Flow &rhs);

template <typename H> H AbslHashValue(H h, const Flow &f) {
  return H::combine(std::move(h), f.src_ip, f.dst_ip, f.src_port, f.dst_port,
                    f.proto);
}

struct FlowUsed {
  Flow flow;
  uint64_t time;
  bool used;

  FlowUsed() : flow(Flow()), time(0), used(false) {}

  FlowUsed(Flow flow, uint64_t time, bool used)
      : flow(flow), time(time), used(used) {}

  friend bool operator==(const FlowUsed &lhs, const FlowUsed &rhs);
};

bool operator==(const FlowUsed &lhs, const FlowUsed &rhs);

template <typename H> H AbslHashValue(H h, const FlowUsed &f) {
  return H::combine(std::move(h), f.flow, f.time, f.used);
}
#include <absl/container/flat_hash_map.h>
#include <absl/hash/hash.h>

#include <cstdint>

#include "nfv.hpp"

class Flow {
  uint32_t src_ip;
  uint32_t dst_ip;
  uint16_t src_port;
  uint16_t dst_port;
  uint8_t proto;

  friend bool operator==(const Flow& lhs, const Flow& rhs);
};

bool operator==(const Flow& lhs, const Flow& rhs) {
  return lhs.src_ip == rhs.src_ip && lhs.dst_ip == rhs.dst_ip &&
         lhs.src_port == rhs.src_port && lhs.dst_port == rhs.dst_port &&
         lhs.proto == rhs.proto;
}

template <typename H>
H AbslHashValue(H h, const Flow& f) {
  return H::combine(std::move(h), f.src_ip, f.dst_ip, f.src_port, f.dst_port,
                    f.proto);
}

// TODO: use FNV?
static absl::flat_hash_map<Flow, Flow, absl::Hash<Flow>> MAP;

extern "C" void nf2_one_way_nat(rte_mbuf* m) {}
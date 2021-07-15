#include "nf4.hpp"

#include <absl/container/flat_hash_map.h>
#include <absl/hash/hash.h>
#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>

#include <cstdint>

extern "C" {
#include "maglev.h"
}
#include "nfv.hpp"
#include "packettool.hpp"

NF4Maglev::NF4Maglev() { maglev_init(); }

void NF4Maglev::_process_frames(const std::span<rte_ether_hdr *> packets) {
  for (auto &&eth_hdr: packets) {
    if (maglev_process_frame(eth_hdr)) {
      swap_mac(eth_hdr);
    }
  }
}
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

extern "C" void nf4_init() { maglev_init(); }

extern "C" void nf4_maglev(rte_mbuf *m) {
  if (maglev_process_frame(rte_pktmbuf_mtod(m, void *),
                           rte_pktmbuf_pkt_len(m)) != 1) {
    // Get packet header.
    swap_mac(m);
  }
}
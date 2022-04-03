#include "nf1.hpp"

#include <tuple>

#include <rte_ether.h>
#include <rte_ip.h>

#include "nfv.hpp"
#include "packettool.hpp"

void NF1DecrementTtl::_process_frames(const std::span<rte_ether_hdr*> packets, int buffer_id) {
  for (auto&& packet : packets) {
    // Get packet header.
    rte_ipv4_hdr* ipv4_hdr = get_ipv4_hdr(packet);
    if (ipv4_hdr == nullptr) {
      continue;
    }
    // Decrement TLL
    ipv4_hdr->time_to_live--;
  }
}

void NF1DecrementTtl::report() {
}

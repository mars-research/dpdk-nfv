#include "nf1.hpp"

#include <tuple>

#include <rte_ether.h>
#include <rte_ip.h>

#include "nfv.hpp"
#include "packettool.hpp"

void NF1DecrementTtl::_process_frames(const std::span<rte_mbuf*> packets) {
  for (auto&& packet : packets) {
    // Get packet header.
    const auto headers = get_packet_headers(packet);
    if (!(headers)) {
      return;
    }
    rte_ipv4_hdr *ipv4_hdr;
    std::tie(std::ignore, ipv4_hdr, std::ignore) = headers.value();

    // Decrement TLL
    ipv4_hdr->time_to_live--;
  }
}

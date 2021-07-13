#include <tuple>

#include <rte_ether.h>
#include <rte_ip.h>

#include "nfv.hpp"
#include "packettool.hpp"

std::tuple<int, bool> f() { return {0, false}; }

extern "C" void _nf1_decrement_ttl(rte_mbuf *m) {
  // Get packet header.
  const auto headers = get_packet_headers(m);
  if (!(headers)) {
    return;
  }
  rte_ipv4_hdr *ipv4_hdr;
  std::tie(std::ignore, ipv4_hdr, std::ignore) = headers.value();

  // Decrement TLL
  ipv4_hdr->time_to_live--;
}

#include <rte_ether.h>
#include <rte_ip.h>

#include "nfv.hpp"

extern "C" void nf1_decrement_ttl(rte_mbuf *m) {
  // Get ethernet header.
  rte_ether_hdr *eth_hdr = rte_pktmbuf_mtod(m, struct rte_ether_hdr *);

  // Get IPv4 heaver.
  if(eth_hdr->ether_type != rte_cpu_to_be_16(RTE_ETHER_TYPE_IPV4)) {
    return;
  }
  struct rte_ipv4_hdr *ipv4_hdr =
      (struct rte_ipv4_hdr *)((uint8_t *)eth_hdr +
                              sizeof(struct rte_ether_hdr));

  // Decrement TLL
  ipv4_hdr->time_to_live--;
}
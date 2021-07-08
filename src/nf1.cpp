#include <rte_ether.h>
#include <rte_ip.h>

#include "nfv.hpp"

extern "C" void nf1_decrement_ttl(rte_mbuf *m) {
  // Get ethernet header.
  rte_ether_hdr *eth_hdr = rte_pktmbuf_mtod(m, struct rte_ether_hdr *);

  // Get IPv4 heaver.
  void *l3 = (uint8_t *)eth_hdr + sizeof(struct rte_ether_hdr);
  uint16_t ether_type = eth_hdr->ether_type;
  assert(ether_type == rte_cpu_to_be_16(RTE_ETHER_TYPE_IPV4));
  struct rte_ipv4_hdr *ipv4_hdr = (struct rte_ipv4_hdr *)l3;

  // Decrement TLL
  ipv4_hdr->time_to_live--;

  // Calls nf2
  nf2_one_way_nat(m);
}
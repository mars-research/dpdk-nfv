#ifndef _RLTEST_PACKETTOOL_H
#define _RLTEST_PACKETTOOL_H

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
};

struct rte_ipv4_hdr *get_ipv4_hdr(const struct rte_ether_hdr *eth_hdr);


struct  rte_ipv4_hdr* get_packet_rte_ipv4_hdr(
    struct rte_ether_hdr *eth_hdr);
    
struct  rte_udp_hdr* get_packet_rte_udp_hdr(
    struct rte_ether_hdr *eth_hdr);

void copy_flow(struct Flow * src, struct Flow* dst);
bool cmp_flow(struct Flow * src, struct Flow* dst);
void ipv4_stamp_flow(struct Flow * outgoing_flow, struct rte_ipv4_hdr *ipv4_hdr, struct rte_udp_hdr *udp_hdr);
#endif

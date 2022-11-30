#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>
#include "packettool.h"
#include "hashmap.h"

struct Acl {
  rte_be32_t src_ip;
  rte_be32_t dst_ip;
  rte_be16_t src_port;
  rte_be16_t dst_port;
  // Related not done
  bool drop;

}Acl;

size_t acls_cap = CAPACITY<<2;
size_t acls_count = 1;
struct Acl acls[CAPACITY<<2] = {
  [0].src_ip = 0, // 10.0.0.1
  [0].dst_ip = 0, // 10.0.0.2
  [0].src_port = 0,
  [0].dst_port = 0,
  [0].drop = false,
};

bool matches(struct Acl * this, struct Flow *flow){
   bool src_ip_matched =
      this->src_ip == 0 || this->src_ip == flow->src_ip;
   bool dst_ip_matched =
      this->dst_ip == 0 || this->dst_ip == flow->dst_ip;
   bool src_port_matched =
      this->src_port == 0 || this->src_port == flow->src_port;
   bool dst_port_matched =
      this->dst_port == 0 || this->dst_port == flow->dst_port;


  return src_ip_matched && dst_ip_matched && src_port_matched &&
    dst_port_matched;
}

size_t process_frames(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id){
  for (int i = 0; i < nb_rx; i++) {
    // Get packet header.
    struct rte_ether_hdr *eth_hdr = packets[i];

    struct rte_ipv4_hdr *ipv4_hdr = get_packet_rte_ipv4_hdr(eth_hdr);
    struct rte_udp_hdr *udp_hdr = get_packet_rte_udp_hdr(eth_hdr);


    if (ipv4_hdr == NULL || udp_hdr == NULL ){
      return 0;
    }

    // Extract flow.
    struct Flow flow = {.src_ip = ipv4_hdr->src_addr,
         .dst_ip = ipv4_hdr->dst_addr,
         .src_port = udp_hdr->src_port,
         .dst_port = udp_hdr->dst_port,
         .proto = eth_hdr->ether_type};

    bool matched = false;

    // check if the flow is matched directly by the ACL
    for (int i = 0; i< acls_count; i++) {
        struct Acl *acl = &acls[i];

      if (matches(acl, &flow)) {
        matched = true;
        if (!acl->drop) {
          maglev_hashmap_insert(&flow,NULL);
        }
        break;
      }
    }

    if (!matched) {
      // check if the reverse flow is in the cache
      struct Flow reversed_flow = {
        .src_ip = flow.dst_ip,
        .dst_ip = flow.src_ip,
        .src_port = flow.dst_port,
        .dst_port = flow.src_port,
        .proto = flow.proto
      };

      if (maglev_hashmap_get(&reversed_flow) != NULL) {
        matched = true;
      }
    }

    if (!matched) {
      // TODO: we drop the packet here
    }
    asm volatile("" : "+r"(matched));
  }
}

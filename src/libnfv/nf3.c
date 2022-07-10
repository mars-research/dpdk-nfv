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
  bool established;
  // Related not done
  bool drop;

}Acl;

size_t acls_cap = CAPACITY<<2;
size_t acls_count = 0;
struct Acl acls[CAPACITY<<2];

bool matches(struct Acl * this, struct Flow *flow){
   bool src_ip_matched =
      !this->src_ip != NULL || this->src_ip == flow->src_ip;
   bool dst_ip_matched =
      !this->dst_ip != NULL || this->dst_ip == flow->dst_ip;
   bool src_port_matched =
      !this->src_port != NULL || this->src_port == flow->src_port;
   bool dst_port_matched =
      !this->dst_port != NULL || this->dst_port == flow->dst_port;

  if (src_ip_matched && dst_ip_matched && src_port_matched &&
      dst_port_matched) {
    if (this->established) {
      // If the flow is already established by the destination, we will let it
      // pass if `established` is set to true.
    struct Flow reversed_flow = {.src_ip = flow->dst_ip,
         .dst_ip = flow->src_ip,
         .src_port = flow->dst_port,
         .dst_port = flow->src_port,
         .proto = flow->proto};
      return maglev_hashmap_get(flow)!=NULL||
             ((maglev_hashmap_get(&reversed_flow)!=NULL)== this->established);
    }
    return true;
  }
  return false;
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
    
    for (int i = 0; i< acls_count; i++) {
        struct Acl *acl = &acls[i];
      if (matches(acl, &flow)) {
        if (!acl->drop) {
          maglev_hashmap_insert(&flow,NULL);
        }
        // return !acl.drop;
      }
    }
  }
}
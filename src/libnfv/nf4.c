#include "maglev.h"
#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>

size_t process_frames(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id){
  for (int i = 0; i < nb_rx; i++) {
    // Get packet header.
    struct rte_ether_hdr *eth_hdr = packets[i];
    int64_t backend = maglev_process_frame(eth_hdr);
    if (backend) {
      eth_hdr->dst_addr.addr_bytes[5] = (char)backend;
    }
  }
}

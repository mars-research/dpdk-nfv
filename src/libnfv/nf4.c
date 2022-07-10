#include "maglev.h"
#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>

size_t process_frames(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id){
  for (int i = 0; i < nb_rx; i++) {
    // Get packet header.
    struct rte_ether_hdr *eth_hdr = packets[i];
    if(maglev_process_frame(eth_hdr)) {
         swap_mac(eth_hdr);
    }



  }
}
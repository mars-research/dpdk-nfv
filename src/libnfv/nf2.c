#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>
#include "packettool.h"
#include "hashmap.h"

const static size_t MAX_SIZE = 1 << 16;
const static uint16_t MIN_PORT = 1024;
const static uint16_t MAX_PORT = 65535;

uint16_t next_port_ = MIN_PORT;


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

    // Check if the flow is already NATed.
    struct maglev_kv_pair * pair = maglev_hashmap_get(&flow);
    if (pair != NULL) {
      // Stamp the pack with the outgoing flow.
      struct Flow * outgoing_flow = &pair->value;
      ipv4_stamp_flow(outgoing_flow,ipv4_hdr, udp_hdr);
    } else if (next_port_ < MAX_PORT) {
      // Allocate a new port.
      uint16_t assigned_port = next_port_;
      next_port_++;

      // Update flow_vec
      //flow_vec_[assigned_port] = {flow, 0, true};

      // Create a new outgoing flow.
      struct Flow outgoing_flow = {.src_ip = ipv4_hdr->src_addr,
         .dst_ip = ipv4_hdr->dst_addr,
         .src_port = assigned_port,
         .dst_port = udp_hdr->dst_port,
         .proto = eth_hdr->ether_type};
      //outgoing_flow.src_port = assigned_port;

      // Update flow mapping.
      maglev_hashmap_insert(&flow, &outgoing_flow);

      struct Flow outgoing_flow_r = {.src_ip = outgoing_flow_r.dst_ip,
         .dst_ip = outgoing_flow_r.src_ip,
         .src_port = outgoing_flow_r.dst_port,
         .dst_port = outgoing_flow_r.src_port,
         .proto = outgoing_flow_r.proto};

      struct Flow flow_r = {.src_ip = flow_r.dst_ip,
         .dst_ip = flow_r.src_ip,
         .src_port = flow_r.dst_port,
         .dst_port = flow_r.src_port,
         .proto = flow_r.proto};
      maglev_hashmap_insert(&outgoing_flow_r, &flow_r);

      // Stamp the pack with the outgoing flow.
      ipv4_stamp_flow(&outgoing_flow,ipv4_hdr, udp_hdr);
    }
  }
}
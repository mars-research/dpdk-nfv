#include <rte_ether.h>
#include <rte_mbuf.h>
#include "../../user-trampoline/loader.h"

extern size_t (*_nf1)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id);
extern size_t (*_nf2)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id);
extern size_t (*_nf3)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id);
extern size_t (*_nf4)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id);

size_t (nf1)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id);
size_t (nf2)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id);
size_t (nf3)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id);
size_t (nf4)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id);

void run_nfs(struct rte_ether_hdr **packets, uint64_t pkt_len);
void init_nfs(void* not_used_pointer,size_t not_used_int);

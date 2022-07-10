#ifndef _MAGLEV_DPDK_H_
#define _MAGLEV_DPDK_H_

#include "packettool.h"
#include <rte_ether.h>
#include <rte_ip.h>
#include <rte_udp.h>
#include "maglev.h"
#define CAPACITY ((1ULL << 20) * 16)



/* maglev KV pair */
struct maglev_kv_pair {
    uint64_t key;
    uint64_t value;
};


struct maglev_hashmap {
    struct maglev_kv_pair *pairs;
};

// Maglev Init
void maglev_init(void);

// Maglev process frame
int64_t maglev_process_frame(struct rte_ether_hdr *frame);


#endif /* _MAGLEV_DPDK_H_ */

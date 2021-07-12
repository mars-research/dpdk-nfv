#include <rte_mbuf.h>

#ifdef __cplusplus
extern "C" {
#endif

// Function pointer type of a network function.
typedef void (*nfv_fn_t)(struct rte_mbuf *m);

// NF1: decrement TTL.
void nf1_decrement_ttl(struct rte_mbuf *m);

// NF2: one way NAT.
void nf2_init();
void nf2_one_way_nat(struct rte_mbuf *m);

// NF3: ACL.
void nf3_init();
void nf2_one_way_nat(struct rte_mbuf *m);

#ifdef __cplusplus  
}
#endif

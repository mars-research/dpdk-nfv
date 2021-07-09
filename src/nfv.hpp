#include <rte_mbuf.h>

#ifdef __cplusplus
extern "C" typedef void (*nfv_fn_t)(rte_mbuf *m);
#else
typedef void (*nfv_fn_t)(struct rte_mbuf *m);
#endif

// NF1: decrement TTL
#ifdef __cplusplus
extern "C" void nf1_decrement_ttl(rte_mbuf *m);
#else
void nf1_decrement_ttl(struct rte_mbuf *m);
#endif

// NF2: one way NAT
#ifdef __cplusplus
extern "C" void nf2_init();
extern "C" void nf2_one_way_nat(rte_mbuf *m);
#else
void nf2_init();
void nf2_one_way_nat(struct rte_mbuf *m);
#endif

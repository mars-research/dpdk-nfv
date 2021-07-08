#include <rte_mbuf.h>

// NF1: decrement TTL
#ifdef __cplusplus
extern "C"
#endif
    void
    nf1_decrement_ttl(struct rte_mbuf *m);

// NF1: decrement TTL
#ifdef __cplusplus
extern "C"
#endif
    void
    nf2_one_way_nat(struct rte_mbuf *m);

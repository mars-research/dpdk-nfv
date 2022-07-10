#include "nfv.h"

size_t (*_nf1)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;
size_t (*_nf2)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;
size_t (*_nf3)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;
size_t (*_nf4)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;


void run_nfs(struct rte_ether_hdr **packets, uint64_t pkt_len) {
    nf1(packets,pkt_len,0,13);
    //nf2(packets,pkt_len,0,13);
    //nf3(packets,pkt_len,0,13);
    //nf4(packets,pkt_len,0,13);
}

void* alloc_1(size_t request ){
return buddy_alloc( request,buddy_a);
}


void Load_nf1(){
	extern int CURRENT_DOM;
    extern int pkey_a;
    CURRENT_DOM = 1;
  	struct elf_domain * elf_a = load_elf_domain("/users/BUXD/DOIY/dpdk-nfv/src/libnfv/nf1.so", alloc_1, pkey_a);
 	 _nf1 = find_symbol(elf_a, "process_frames");
	 CURRENT_DOM = 0;
 }
void init_nfs(){
	Load_nf1();
}
#include "nfv.h"

size_t (*_nf1)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;
size_t (*_nf2)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;
size_t (*_nf3)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;
size_t (*_nf4)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;
void (*nf4_init)();

void run_nfs(struct rte_ether_hdr **packets, uint64_t pkt_len) {
    nf1(packets,pkt_len,0,13);
    nf2(packets,pkt_len,0,13);
    nf3(packets,pkt_len,0,13);
    nf4(packets,pkt_len,0,13);
}

void* alloc_1(size_t request ){
return buddy_alloc( request,buddy_a);
}

void* alloc_2(size_t request ){
return buddy_alloc( request,buddy_b);
}

void* alloc_3(size_t request ){
return buddy_alloc( request,buddy_c);
}

void* alloc_4(size_t request ){
return buddy_alloc( request,buddy_d);
}



void Load_nf1(){
	extern int CURRENT_DOM;
    extern int pkey_a;
    CURRENT_DOM = 1;
  	struct elf_domain * elf_a = load_elf_domain("/users/BUXD/DOIY/dpdk-nfv/src/libnfv/nf1.so", alloc_1, pkey_a);
 	 _nf1 = find_symbol(elf_a, "process_frames");
	 CURRENT_DOM = 0;
 }
 void Load_nf2(){
	extern int CURRENT_DOM;
    extern int pkey_b;
    CURRENT_DOM = 2;
  	struct elf_domain * elf_a = load_elf_domain("/users/BUXD/DOIY/dpdk-nfv/src/libnfv/nf2.so", alloc_2, pkey_b);
 	 _nf2 = find_symbol(elf_a, "process_frames");
	 CURRENT_DOM = 0;
 }
 void Load_nf3(){
	extern int CURRENT_DOM;
    extern int pkey_c;
    CURRENT_DOM = 3;
  	struct elf_domain * elf_a = load_elf_domain("/users/BUXD/DOIY/dpdk-nfv/src/libnfv/nf3.so", alloc_3, pkey_c);
 	 _nf3 = find_symbol(elf_a, "process_frames");
	 CURRENT_DOM = 0;
 }
 void Load_nf4(){
	extern int CURRENT_DOM;
    extern int pkey_d;
    CURRENT_DOM = 4;
  	struct elf_domain * elf_a = load_elf_domain("/users/BUXD/DOIY/dpdk-nfv/src/libnfv/nf4.so", alloc_4, pkey_d);
 	 _nf4 = find_symbol(elf_a, "process_frames");
	 nf4_init = find_symbol(elf_a, "maglev_init");
	 nf4_init();
	 CURRENT_DOM = 0;
 }

void init_nfs(void* not_used_pointer,size_t not_used_in0t){
	Load_nf1();
    Load_nf2();
    Load_nf3();
	Load_nf4();
}
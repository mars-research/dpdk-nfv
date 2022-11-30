#include "nfv.h"
void * domain_alloc(size_t sz, int id);
#define MTU 1500

size_t (*_nf1)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;
size_t (*_nf2)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;
size_t (*_nf3)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;
size_t (*_nf4)(struct rte_ether_hdr** packets,int nb_rx, int not_used,int buffer_id)__attribute__ ( (section (".ro_trampoline_data")) );;
void (*nf4_init)();

struct rte_ether_hdr * packets_a;
struct rte_ether_hdr * packets_b;
struct rte_ether_hdr * packets_c;
struct rte_ether_hdr * packets_d;

struct rte_ether_hdr ** packets_a_ptr;
struct rte_ether_hdr ** packets_b_ptr;
struct rte_ether_hdr ** packets_c_ptr;
struct rte_ether_hdr ** packets_d_ptr;

void run_nfs(struct rte_ether_hdr **packets, uint64_t pkt_len) {

	for (int i = 0; i < pkt_len; i++) {
		memcpy(&packets_a[i],packets[i],MTU );
	}
	
    nf1(packets,pkt_len,0,13);

	memcpy(packets_b,packets_a,pkt_len * MTU );
    nf2(packets,pkt_len,0,13);

	memcpy(packets_c,packets_b,pkt_len * MTU );
    nf3(packets,pkt_len,0,13);

	memcpy(packets_d,packets_c,pkt_len * MTU );
    nf4(packets,pkt_len,0,13);

	for (int i = 0; i < pkt_len; i++) {
		memcpy(packets[i],&packets_d[i],MTU );
	}

}


void Load_nf1(){
	packets_a = domain_alloc(MTU * 64, 1);
	printf("domain_alloc :%p \n",domain_alloc(MTU * 64, 1));
	 packets_a_ptr = domain_alloc(8 * 64, 1);
  	struct elf_domain * elf_a = load_elf_domain("src/libnfv/nf1.so", 1);
 	 _nf1 = find_symbol(elf_a, "process_frames");
 }
 void Load_nf2(){
  	struct elf_domain * elf_a = load_elf_domain("src/libnfv/nf2.so", 2);
 	 _nf2 = find_symbol(elf_a, "process_frames");
	 packets_b = domain_alloc(MTU * 64, 2);
	 packets_b_ptr = domain_alloc(8 * 64, 2);
 }
 void Load_nf3(){
  	struct elf_domain * elf_a = load_elf_domain("src/libnfv/nf3.so", 3);
 	 _nf3 = find_symbol(elf_a, "process_frames");
	packets_c = domain_alloc(MTU * 64, 3);
	packets_c_ptr = domain_alloc(8 * 64, 3);
 }
 void Load_nf4(){
  	struct elf_domain * elf_a = load_elf_domain("src/libnfv/nf4.so", 4);
 	 _nf4 = find_symbol(elf_a, "process_frames");
	 nf4_init = find_symbol(elf_a, "maglev_init");
	 nf4_init();
	printf("nf4 inited\n");
		// asm("int3");
	packets_d = domain_alloc(MTU * 64, 4);
	packets_d_ptr = domain_alloc(8 * 64, 4);
 }

void init_nfs(void* not_used_pointer,size_t not_used_in0t){
	Load_nf1();
    Load_nf2();
    Load_nf3();
	Load_nf4();
	
	for (int i = 0; i < 64; i++){
		
		char * pkt = (char*)packets_a + i * MTU;
		packets_a_ptr[i] = pkt;
	}
	for (int i = 0; i < 64; i++){
		char * pkt = (char*)packets_b + i * MTU;
		packets_b_ptr[i] = pkt;
	}
	for (int i = 0; i < 64; i++){
		char * pkt = (char*)packets_c + i * MTU;
		packets_c_ptr[i] = pkt;
	}
	for (int i = 0; i < 64; i++){
		char * pkt = (char*)packets_d + i * MTU;
		packets_d_ptr[i] = pkt;
	}
}
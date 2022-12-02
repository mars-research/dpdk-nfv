#include "nfv.h"
#include <dlfcn.h>

void tag_buffer(void* buffer, size_t  len, int Domain_id);

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


void Load_nf1(){
	extern int CURRENT_DOM;
    extern int pkey_a;
    CURRENT_DOM = 1;
  	// struct elf_domain * elf_a = load_elf_domain("src/libnfv/nf1.so", pkey_a);
	void    *handle;
	handle = dlopen("src/libnfv/nf1.so", RTLD_LOCAL |RTLD_NOW);
	if(handle == NULL)
	{
    	printf("Error: %s\n",  dlerror());
		abort();
	}
 	 _nf1 = dlsym(handle, "process_frames1");
		void * domain_start = dlsym(handle,"_domain_start");
	 void * domain_end = dlsym(handle,"_domain_end");
	 printf("_domain_a_start %p\n",dlsym(handle,"_domain_start"));
	 printf("_domain_a_end %p\n",dlsym(handle,"_domain_end"));
	 tag_buffer(domain_start, domain_end - domain_start, pkey_a);
	 CURRENT_DOM = 0;
 }
 void Load_nf2(){
	extern int CURRENT_DOM;
	extern int pkey_a;
    extern int pkey_b;
    CURRENT_DOM = 2;
	void    *handle;
	handle = dlopen("src/libnfv/nf2.so", RTLD_LOCAL |RTLD_NOW);
	if(handle == NULL)
	{
    	printf("Error: %s\n",  dlerror());
		abort();
	}
 	 _nf2 = dlsym(handle,"process_frames2");
	 void * domain_start = dlsym(handle,"_domain_start");
	 void * domain_end = dlsym(handle,"_domain_end");
	 printf("_domain_b_start %p\n",dlsym(handle,"_domain_start"));
	 printf("_domain_b_end %p\n",dlsym(handle,"_domain_end"));
	 tag_buffer(domain_start, domain_end - domain_start, pkey_b);
	 CURRENT_DOM = 0;
 }
 void Load_nf3(){
	extern int CURRENT_DOM;
	extern int pkey_a;
    extern int pkey_c;
    CURRENT_DOM = 3;
	void    *handle;
	handle = dlopen("src/libnfv/nf3.so", RTLD_LOCAL | RTLD_NOW);
	if(handle == NULL)
	{
    	printf("Error: %s\n",  dlerror());
		abort();
	}
 	 _nf3 = dlsym(handle, "process_frames3");
	void * domain_start = dlsym(handle,"_domain_start");
	 void * domain_end = dlsym(handle,"_domain_end");
	 printf("_domain_c_start %p\n",dlsym(handle,"_domain_start"));
	 printf("_domain_c_end %p\n",dlsym(handle,"_domain_end"));
	 tag_buffer(domain_start, domain_end - domain_start, pkey_c);
	 CURRENT_DOM = 0;
 }
 void Load_nf4(){
	extern int CURRENT_DOM;
	extern int pkey_a;
    extern int pkey_d;
    CURRENT_DOM = 4;
	void    *handle;
	handle = dlopen("src/libnfv/nf4.so", RTLD_LOCAL |RTLD_NOW);
	if(handle == NULL)
	{
    	printf("Error: %s\n",  dlerror());
		abort();
	}
 	 _nf4 = dlsym(handle, "process_frames4");
	 nf4_init = dlsym(handle, "nf4_init");
	 printf("_nf4 %p\n",_nf4);
	 nf4_init();
	void * domain_start = dlsym(handle,"_domain_start");
	 void * domain_end = dlsym(handle,"_domain_end");
	 printf("_domain_d_start %p\n",dlsym(handle,"_domain_start"));
	 printf("_domain_d_end %p\n",dlsym(handle,"_domain_end"));
	 tag_buffer(domain_start, domain_end - domain_start, pkey_d);
	 CURRENT_DOM = 0;
 }

void init_nfs(void* not_used_pointer,size_t not_used_in0t){
	Load_nf1();
    Load_nf2();
    Load_nf3();
	Load_nf4();
}
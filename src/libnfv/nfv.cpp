#include "nfv.hpp"

#include <span>

#include <rte_ether.h>

#include "nf1.hpp"
#include "nf2.hpp"
#include "nf3.hpp"
#include "nf4.hpp"
#include "nfv.hpp"

static std::vector<std::unique_ptr<NetworkFunction>> NFS;

extern "C" void init_nfs() {
  NFS.emplace_back(std::make_unique<NF1DecrementTtl>());
  NFS.emplace_back(std::make_unique<NF2OneWayNat>());
  NFS.emplace_back(std::make_unique<NF3Acl>(std::vector{Acl{
    src_ip : 0,
    dst_ip : {},
    src_port : {},
    dst_port : {},
    established : {},
    drop : false,
  }}));
  NFS.emplace_back(std::make_unique<NF4Maglev>());
}

extern "C" void run_nfs(rte_ether_hdr **packets, uint64_t pkt_len) {
  const std::span<rte_ether_hdr *> packets_span(packets, pkt_len);
  for (auto &&nf : NFS) {
    nf->process_frames(packets_span);
  }
}

extern "C" void report_nfs() {
  for (auto &&nf : NFS) {
    nf->report();
  }
}

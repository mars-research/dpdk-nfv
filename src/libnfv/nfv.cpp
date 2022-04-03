#include "nfv.hpp"

#include <span>

#include <rte_ether.h>

#include "nf1.hpp"
#include "nf2.hpp"
#include "nf3.hpp"
#include "nf4.hpp"
#include "nfv.hpp"

static std::vector<std::unique_ptr<NetworkFunction>> NFS;

extern "C" void init_nfs(uint8_t *nfs, uint64_t len) {

  for (const auto &nf : std::span<uint8_t>(nfs, len)) {
    switch (nf) {
    case 1:
      NFS.emplace_back(std::make_unique<NF1DecrementTtl>());
      break;

    case 2:
      NFS.emplace_back(std::make_unique<NF2OneWayNat>());
      break;

    case 3:
      NFS.emplace_back(std::make_unique<NF3Acl>(std::vector{Acl{
        src_ip : 0,
        dst_ip : {},
        src_port : {},
        dst_port : {},
        established : {},
        drop : false,
      }}));
      break;

    case 4:
      NFS.emplace_back(std::make_unique<NF4Maglev>());
      break;

    default:
      fprintf(stderr, "Bad nf %d\n", nf);
      break;
    }
  }
}

extern "C" void run_nfs(rte_ether_hdr **packets, uint64_t pkt_len) {
  const std::span<rte_ether_hdr *> packets_span(packets, pkt_len);
  for (auto &&nf : NFS) {
    nf->process_frames(packets_span,13); //domain_m for now.
  }
}

extern "C" void report_nfs() {
  for (auto &&nf : NFS) {
    nf->report();
  }
}

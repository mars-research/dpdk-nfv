#pragma once

#include <span>

#include <rte_ether.h>
#include <rte_mbuf.h>

class NetworkFunction {
 private:
  virtual void _process_frames(const std::span<rte_ether_hdr*> packets) = 0;

 public:
  virtual void process_frames(const std::span<rte_ether_hdr*> packets) = 0;
  virtual void report() {}
  virtual ~NetworkFunction() = default;
};

extern "C" void init_nfs(uint8_t *nfs, uint64_t len);
extern "C" void run_nfs(rte_ether_hdr** packets, uint64_t pkt_len);
extern "C" void report_nfs();

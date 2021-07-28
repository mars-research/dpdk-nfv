#pragma once

#include <rte_mbuf.h>

#include "nfv.hpp"

class NF4Maglev : public NetworkFunction {
 private:
  void _process_frames(const std::span<rte_ether_hdr*> packets) override;

 public:
  NF4Maglev();

  void process_frames(const std::span<rte_ether_hdr*> packets) override;
};
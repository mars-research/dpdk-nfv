#pragma once

#include <rte_mbuf.h>

#include "nfv.hpp"

class NF1DecrementTtl : public NetworkFunction {
private:
  void _process_frames(const std::span<rte_ether_hdr*> packets) override;

public:
  void process_frames(const std::span<rte_ether_hdr*> packets) override;
};
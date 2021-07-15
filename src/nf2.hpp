#pragma once

#include <vector>

#include <rte_mbuf.h>
#include <absl/container/flat_hash_map.h>

#include "nfv.hpp"
#include "packettool.hpp"

class NF2OneWayNat : public NetworkFunction {
private:
  const static size_t MAX_SIZE = 1 << 16;
  const static uint16_t MIN_PORT = 1024;
  const static uint16_t MAX_PORT = 65535;
  
  uint16_t next_port_ = MIN_PORT;
  absl::flat_hash_map<Flow, Flow, absl::Hash<Flow>> port_hash_;
  std::vector<FlowUsed> flow_vec_;

  void _process_frames(const std::span<rte_mbuf*> packets) override;

public:
  NF2OneWayNat();

  void process_frames(const std::span<rte_mbuf*> packets) override;
};
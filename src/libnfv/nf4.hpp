#pragma once

#include <rte_mbuf.h>

#include "nfv.hpp"

class NF4Maglev : public NetworkFunction {
 private:
  void _process_frames(const std::span<rte_ether_hdr*> packets, int buffer_id) __attribute__ ((section (".domain_d"))) ;;

 public:
  NF4Maglev();

  void process_frames(const std::span<rte_ether_hdr*> packets, int buffer_id) override;
};
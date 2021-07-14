#pragma once

#include <rte_mbuf.h>

#include "nfv.hpp"

class NF1DecrementTtl : public NetworkFunction {
private:
  void _process_frame(rte_mbuf *m) override;

public:
  void process_frame(rte_mbuf *m) override;
};
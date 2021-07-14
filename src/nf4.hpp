#pragma once

#include <rte_mbuf.h>

#include "nfv.hpp"

class NF4Maglev : public NetworkFunction {
private:
  void _process_frame(rte_mbuf *m) override;

public:
  NF4Maglev();

  void process_frame(rte_mbuf *m) override;
};
#pragma once

#include <span>

#include <rte_mbuf.h>

constexpr size_t MAX_PKT_BURST = 32;

class NetworkFunction {
private:
    virtual void _process_frames(const std::span<rte_mbuf*> packets) = 0;
public:
    virtual void process_frames(const std::span<rte_mbuf*> packets) = 0;
    virtual ~NetworkFunction() {}
};

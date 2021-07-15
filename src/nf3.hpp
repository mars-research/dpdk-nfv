#pragma once

#include <optional>

#include <absl/container/flat_hash_set.h>
#include <rte_mbuf.h>

#include "nfv.hpp"
#include "packettool.hpp"


struct Acl {
  std::optional<rte_be32_t> src_ip;
  std::optional<rte_be32_t> dst_ip;
  std::optional<rte_be16_t> src_port;
  std::optional<rte_be16_t> dst_port;
  std::optional<bool> established;
  // Related not done
  bool drop;

  bool matches(const Flow &flow,
              const absl::flat_hash_set<Flow> &connections) const;
};

class NF3Acl : public NetworkFunction {
private:
  absl::flat_hash_set<Flow> flow_cache_;
  std::vector<Acl> acls_;

  void _process_frames(const std::span<rte_ether_hdr*> packets) override;

public:
  NF3Acl(const std::vector<Acl> acls);

  void process_frames(const std::span<rte_ether_hdr*> packets) override;
};
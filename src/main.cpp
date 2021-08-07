/* SPDX-License-Identifier: BSD-3-Clause
 * Copyright(c) 2010-2016 Intel Corporation
 */

// Borrowed from
// https://github.com/DPDK/dpdk/blob/02e077f35dbc9821dfcb32714ad1096a3ee58d08/examples/l2fwd/main.c

#include <absl/flags/flag.h>
#include <absl/flags/parse.h>
#include <absl/flags/usage.h>
#include <chrono>
#include <ctype.h>
#include <errno.h>
#include <functional>
#include <getopt.h>
#include <inttypes.h>
#include <iomanip>
#include <iostream>
#include <limits>
#include <memory>
#include <setjmp.h>
#include <signal.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include <sys/queue.h>
#include <sys/types.h>
#include <tuple>
#include <unordered_set>
#include <vector>
#ifdef PAPI
#include <papi.h>
#endif

#include <rte_atomic.h>
#include <rte_branch_prediction.h>
#include <rte_common.h>
#include <rte_cycles.h>
#include <rte_debug.h>
#include <rte_eal.h>
#include <rte_ethdev.h>
#include <rte_ether.h>
#include <rte_interrupts.h>
#include <rte_launch.h>
#include <rte_lcore.h>
#include <rte_log.h>
#include <rte_malloc.h>
#include <rte_mbuf.h>
#include <rte_memcpy.h>
#include <rte_memory.h>
#include <rte_mempool.h>
#include <rte_per_lcore.h>
#include <rte_prefetch.h>
#include <rte_random.h>
#include <rte_string_fns.h>

#include "nfv.hpp"
extern "C" {
#include "../user-trampoline/rt.h"
}

const std::vector<std::string> default_nfs = {"1", "2", "3", "4"};
ABSL_FLAG(std::vector<std::string>, network_functions, default_nfs,
          "A list of network functions enabled.");
ABSL_FLAG(uint64_t, timer_period, 10,
          "Frequency of invocation of `print_stats` in seconds.");
ABSL_FLAG(uint64_t, max_timer_period, std::numeric_limits<uint64_t>::max(),
          "Maximum timer period elapsed before shutting down.");
ABSL_FLAG(uint64_t, max_packets, std::numeric_limits<uint64_t>::max(),
          "Number of packets processed before shutting down.");
ABSL_FLAG(uint32_t, portmask, 0,
          "Hexadecimal bitmask of ports to configure/enable.");
ABSL_FLAG(uint32_t, num_rx_queue, 1, "Number RX queue per lcore.");
ABSL_FLAG(std::vector<std::string>, portmap, std::vector<std::string>{},
          "NOT implemented yet btw.\nConfigure forwarding port pair mapping. "
          "Default: alternate port pairs.");
ABSL_FLAG(bool, offload_ipv4_checksum, true, "Enable hardware IPv4 checksum offloading.");

static_assert((BATCH_SIZE % 4 == 0) || (BATCH_SIZE == 1),
              "rte_rx_burst limitation: 'Some drivers using vector "
              "instructions require that *nb_pkts* is "
              "divisible by 4 or 8, depending on the driver implementation.' "
              "We also support `BATCH_SIZE` by receiving a batch of 4 but "
              "processing one packet at a time."
              "https://github.com/DPDK/dpdk/blob/"
              "02e077f35dbc9821dfcb32714ad1096a3ee58d08/lib/ethdev/"
              "rte_ethdev.h#L4954-L4956)");
/// Maximun number of packets per RX burst.
/// If the `BATCH_SIZE` is one, we receive a burst of 4 but process one packet
/// at a time.
/// constexpr size_t MAX_PKT_BURST = (BATCH_SIZE == 1) ? 4 : BATCH_SIZE;
/// Since requirement changed at the deadline day, burst size is always 32 now.
constexpr size_t MAX_PKT_BURST = 32;

static volatile bool force_quit;

#define RTE_LOGTYPE_L2FWD RTE_LOGTYPE_USER1

#define BURST_TX_DRAIN_US 100 /* TX drain every ~100us */
#define MEMPOOL_CACHE_SIZE 256

/*
 * Configurable number of RX/TX ring descriptors
 */
#define RTE_TEST_RX_DESC_DEFAULT 1024
#define RTE_TEST_TX_DESC_DEFAULT 1024
static uint16_t nb_rxd = RTE_TEST_RX_DESC_DEFAULT;
static uint16_t nb_txd = RTE_TEST_TX_DESC_DEFAULT;

/* ethernet addresses of ports */
static struct rte_ether_addr l2fwd_ports_eth_addr[RTE_MAX_ETHPORTS];

/* list of enabled ports */
static uint32_t l2fwd_dst_ports[RTE_MAX_ETHPORTS];

struct port_pair_params {
#define NUM_PORTS 2
  uint16_t port[NUM_PORTS];
} __rte_cache_aligned;

static struct port_pair_params port_pair_params_array[RTE_MAX_ETHPORTS / 2];
static struct port_pair_params *port_pair_params;
static uint16_t nb_port_pair_params;

#define MAX_RX_QUEUE_PER_LCORE 16
#define MAX_TX_QUEUE_PER_PORT 16
struct lcore_queue_conf {
  unsigned n_rx_port;
  unsigned rx_port_list[MAX_RX_QUEUE_PER_LCORE];
} __rte_cache_aligned;
struct lcore_queue_conf lcore_queue_conf[RTE_MAX_LCORE];

static struct rte_eth_dev_tx_buffer *tx_buffer[RTE_MAX_ETHPORTS];

static struct rte_eth_conf port_conf;

struct rte_mempool *l2fwd_pktmbuf_pool = NULL;

/* Per-port statistics struct */
struct l2fwd_port_statistics {
  uint64_t tx;
  uint64_t rx;
  uint64_t processed;
  // Amount of time spent in processing in cycles.
  uint64_t cycles_processed;
  uint64_t dropped;
} __rte_cache_aligned;
struct l2fwd_port_statistics port_statistics[RTE_MAX_ETHPORTS];
struct l2fwd_port_statistics last_port_statistics[RTE_MAX_ETHPORTS];

static uint64_t last_throughput = 0;
static uint64_t last_latency = 0;

/* Print out statistics on packets dropped */
static void print_stats(void) {
  static std::chrono::steady_clock::time_point last_print_stats_time =
      std::chrono::steady_clock::now();
  static std::optional<uint32_t> l2fwd_enabled_port_mask;

  if (!l2fwd_enabled_port_mask) {
    l2fwd_enabled_port_mask = absl::GetFlag(FLAGS_portmask);
  }

  uint64_t total_packets_dropped, total_packets_tx, total_packets_rx;
  unsigned portid;
  const auto current_time = std::chrono::steady_clock::now();
  typedef std::chrono::duration<double> duration_seconds_t;
  duration_seconds_t duration = current_time - last_print_stats_time;
  last_print_stats_time = current_time;

  total_packets_dropped = 0;
  total_packets_tx = 0;
  total_packets_rx = 0;

  const char clr[] = {27, '[', '2', 'J', '\0'};
  const char topLeft[] = {27, '[', '1', ';', '1', 'H', '\0'};

  /* Clear screen and move to top left */
  printf("%s%s", clr, topLeft);

  printf("\nPort statistics ====================================");

  for (portid = 0; portid < RTE_MAX_ETHPORTS; portid++) {
    /* skip disabled ports */
    if ((*l2fwd_enabled_port_mask & (1 << portid)) == 0)
      continue;

    const auto &stat = port_statistics[portid];
    const auto &last_stat = last_port_statistics[portid];
    const auto processed_delta = stat.processed - last_stat.processed;
    const auto cycles_processed_delta =
        stat.cycles_processed - last_stat.cycles_processed;
    const auto throughput = processed_delta / duration.count();
    last_throughput = throughput;
    const auto latency =
        (double)cycles_processed_delta / std::max(1ul, processed_delta);
    last_latency = latency;

    std::cout << "\nStatistics for port " << portid
              << " ------------------------------"
              << "\nPackets sent: " << port_statistics[portid].tx
              << "\nPackets received: " << port_statistics[portid].rx
              << "\nPackets dropped: " << port_statistics[portid].dropped
              << "\nThroughput: " << throughput << " packets/second"
              << "\nProcessing speed: " << latency << " cycles/packet";

    total_packets_dropped += port_statistics[portid].dropped;
    total_packets_tx += port_statistics[portid].tx;
    total_packets_rx += port_statistics[portid].rx;
  }
  memcpy(last_port_statistics, port_statistics, sizeof(last_port_statistics));
  printf("\nAggregate statistics ==============================="
         "\nTotal packets sent: %18" PRIu64
         "\nTotal packets received: %14" PRIu64
         "\nTotal packets dropped: %15" PRIu64,
         total_packets_tx, total_packets_rx, total_packets_dropped);
  printf("\n====================================================\n");
  printf("\nNetwork function status ===============================\n");
  report_nfs();
  printf("====================================================\n");

  fflush(stdout);
}

/* main processing loop */
static void l2fwd_main_loop(void) {
  struct rte_mbuf *pkts_burst[MAX_PKT_BURST];
  struct rte_ether_hdr *eth_hdrs_burst[MAX_PKT_BURST];
  int sent;
  unsigned lcore_id;
  uint64_t prev_tsc, diff_tsc, cur_tsc, timer_tsc;
  uint64_t i, portid, nb_rx, nb_tx;
  struct lcore_queue_conf *qconf;
  const uint64_t drain_tsc =
      (rte_get_tsc_hz() + US_PER_S - 1) / US_PER_S * BURST_TX_DRAIN_US;
  struct rte_eth_dev_tx_buffer *buffer;
  const uint64_t timer_period = absl::GetFlag(FLAGS_timer_period);
  const uint64_t max_timer_period = absl::GetFlag(FLAGS_max_timer_period);
  const uint64_t max_packets = absl::GetFlag(FLAGS_max_packets);
  uint64_t timer_period_elapsed = 0;

  prev_tsc = 0;
  timer_tsc = 0;

  lcore_id = rte_lcore_id();
  qconf = &lcore_queue_conf[lcore_id];

  if (qconf->n_rx_port == 0) {
    RTE_LOG(INFO, L2FWD, "lcore %u has nothing to do\n", lcore_id);
    return;
  }

  RTE_LOG(INFO, L2FWD, "initializing network functions on lcore %u\n",
          lcore_id);
  // Parse flag.
  const auto network_functions_str = absl::GetFlag(FLAGS_network_functions);
  std::vector<uint8_t> network_functions;
  std::transform(network_functions_str.begin(), network_functions_str.end(),
                 std::back_insert_iterator(network_functions),
                 [](const auto &str) { return std::stoi(str); });
  init_nfs(network_functions.data(), network_functions.size());

  RTE_LOG(INFO, L2FWD, "entering main loop on lcore %u\n", lcore_id);

  for (i = 0; i < qconf->n_rx_port; i++) {
    portid = qconf->rx_port_list[i];
    RTE_LOG(INFO, L2FWD, " -- lcoreid=%u portid=%lu\n", lcore_id, portid);
  }

  while (!force_quit) {
    cur_tsc = rte_rdtsc();

    /*
     * TX burst queue drain
     */
    diff_tsc = cur_tsc - prev_tsc;
    if (unlikely(diff_tsc > drain_tsc)) {
      for (i = 0; i < qconf->n_rx_port; i++) {
        portid = l2fwd_dst_ports[qconf->rx_port_list[i]];
        buffer = tx_buffer[portid];

        sent = rte_eth_tx_buffer_flush(portid, 0, buffer);
        if (sent)
          port_statistics[portid].tx += sent;
      }

      /* if timer is enabled */
      if (timer_period > 0) {
        /* advance the timer */
        timer_tsc += diff_tsc;

        /* if timer has reached its timeout */
        if (unlikely(timer_tsc >= timer_period)) {
          /* do this only on main core */
          if (lcore_id == rte_get_main_lcore()) {
            print_stats();
            /* reset the timer */
            timer_tsc = 0;
            timer_period_elapsed++;
          }
        }
      }

      prev_tsc = cur_tsc;
    }

    /*
     * Read packet from RX queues
     */
    for (i = 0; i < qconf->n_rx_port; i++) {
      // RX
      portid = qconf->rx_port_list[i];
      nb_rx = rte_eth_rx_burst(portid, 0, pkts_burst, MAX_PKT_BURST);
      port_statistics[portid].rx += nb_rx;
      std::span<rte_mbuf *> packets(pkts_burst, nb_rx);

      // Get the eth headers.
      for (uint64_t i = 0; i < nb_rx; i++) {
        eth_hdrs_burst[i] =
            rte_pktmbuf_mtod(pkts_burst[i], struct rte_ether_hdr *);
      }

      // Apply network functions.
      const auto begin = _rdtsc();
#ifdef PAPI
      int retval = PAPI_hl_region_begin("run_nfs");
      assert(retval == PAPI_OK);
#endif
      for (int i = 0; i < nb_rx; i += BATCH_SIZE) {
        run_nfs(eth_hdrs_burst + i, BATCH_SIZE);
      }
#ifdef PAPI
      retval = PAPI_hl_region_end("run_nfs");
      assert(retval == PAPI_OK);
#endif
      unsigned int UNUSED;
      const auto end = _rdtscp(&UNUSED);
      port_statistics[portid].cycles_processed += end - begin;
      port_statistics[portid].processed += nb_rx;

      // TX
      nb_tx = rte_eth_tx_burst(portid, 0, pkts_burst, nb_rx);
      // We drop the packets if tx is not able to keep up with the rate
      // assert(nb_tx == nb_rx);
      port_statistics[portid].tx += nb_tx;
    }
    if ((port_statistics[portid].tx > max_packets) ||
        (timer_period_elapsed > max_timer_period)) {
      force_quit = true;
    }
  }
}

static int l2fwd_launch_one_lcore(__rte_unused void *dummy) {
  l2fwd_main_loop();
  return 0;
}

/*
 * Check port pair config with enabled port mask,
 * and for valid port pair combinations.
 */
static int check_port_pair_config(uint32_t *l2fwd_enabled_port_mask) {
  uint32_t port_pair_config_mask = 0;
  uint32_t port_pair_mask = 0;
  uint16_t index, i, portid;

  for (index = 0; index < nb_port_pair_params; index++) {
    port_pair_mask = 0;

    for (i = 0; i < NUM_PORTS; i++) {
      portid = port_pair_params[index].port[i];
      if ((*l2fwd_enabled_port_mask & (1 << portid)) == 0) {
        printf("port %u is not enabled in port mask\n", portid);
        return -1;
      }
      if (!rte_eth_dev_is_valid_port(portid)) {
        printf("port %u is not present on the board\n", portid);
        return -1;
      }

      port_pair_mask |= 1 << portid;
    }

    if (port_pair_config_mask & port_pair_mask) {
      printf("port %u is used in other port pairs\n", portid);
      return -1;
    }
    port_pair_config_mask |= port_pair_mask;
  }

  *l2fwd_enabled_port_mask &= port_pair_config_mask;

  return 0;
}

/* Check the link status of all ports in up to 9s, and print them finally */
static void check_all_ports_link_status(uint32_t port_mask) {
#define CHECK_INTERVAL 100 /* 100ms */
#define MAX_CHECK_TIME 90  /* 9s (90 * 100ms) in total */
  uint16_t portid;
  uint8_t count, all_ports_up, print_flag = 0;
  struct rte_eth_link link;
  int ret;
  char link_status_text[RTE_ETH_LINK_MAX_STR_LEN];

  printf("\nChecking link status");
  fflush(stdout);
  for (count = 0; count <= MAX_CHECK_TIME; count++) {
    if (force_quit)
      return;
    all_ports_up = 1;
    RTE_ETH_FOREACH_DEV(portid) {
      if (force_quit)
        return;
      if ((port_mask & (1 << portid)) == 0)
        continue;
      memset(&link, 0, sizeof(link));
      ret = rte_eth_link_get_nowait(portid, &link);
      if (ret < 0) {
        all_ports_up = 0;
        if (print_flag == 1)
          printf("Port %u link get failed: %s\n", portid, rte_strerror(-ret));
        continue;
      }
      /* print link status if flag set */
      if (print_flag == 1) {
        rte_eth_link_to_str(link_status_text, sizeof(link_status_text), &link);
        printf("Port %d %s\n", portid, link_status_text);
        continue;
      }
      /* clear all_ports_up flag if any link down */
      if (link.link_status == ETH_LINK_DOWN) {
        all_ports_up = 0;
        break;
      }
    }
    /* after finally printing all link status, get out */
    if (print_flag == 1)
      break;

    if (all_ports_up == 0) {
      printf(".");
      fflush(stdout);
      rte_delay_ms(CHECK_INTERVAL);
    }

    /* set the print_flag if all ports up or timeout */
    if (all_ports_up == 1 || count == (MAX_CHECK_TIME - 1)) {
      print_flag = 1;
      printf("done\n");
    }
  }
}

static void signal_handler(int signum) {
  if (signum == SIGINT || signum == SIGTERM) {
    printf("\n\nSignal %d received, preparing to exit...\n", signum);
    force_quit = true;
  }
}

int main(int argc, char **argv) {
  // Setup stdout
  std::cout.imbue(std::locale());
  std::cout << std::fixed;
  std::cout << std::setprecision(2);

  // Initialize RT
  RT_init();

  struct lcore_queue_conf *qconf;
  int ret;
  uint16_t nb_ports;
  uint16_t nb_ports_available = 0;
  uint16_t portid, last_port;
  unsigned lcore_id, rx_lcore_id;
  unsigned nb_ports_in_mask = 0;
  unsigned int nb_lcores = 0;
  unsigned int nb_mbufs;

  /* init EAL */
  ret = rte_eal_init(argc, argv);
  if (ret < 0)
    rte_exit(EXIT_FAILURE, "Invalid EAL arguments\n");
  argc -= ret;
  argv += ret;

  force_quit = false;
  signal(SIGINT, signal_handler);
  signal(SIGTERM, signal_handler);

  /* parse application arguments (after the EAL ones) */
  absl::SetProgramUsageMessage("$PROGRAM [EAL options] -- [program options]");
  absl::ParseCommandLine(argc, argv);

  /* Get command line arguments */
  uint32_t l2fwd_enabled_port_mask = absl::GetFlag(FLAGS_portmask);
  const uint32_t l2fwd_rx_queue_per_lcore = absl::GetFlag(FLAGS_num_rx_queue);
  assert(l2fwd_rx_queue_per_lcore < MAX_RX_QUEUE_PER_LCORE);
  const bool offload_ipv4_checksum = absl::GetFlag(FLAGS_offload_ipv4_checksum);

  /* convert to number of cycles */
  absl::SetFlag(&FLAGS_timer_period,
                absl::GetFlag(FLAGS_timer_period) * rte_get_timer_hz());

  // Enable TX checksum offloading
  if (offload_ipv4_checksum) {
    port_conf.txmode.offloads |= DEV_TX_OFFLOAD_IPV4_CKSUM;
  }

  nb_ports = rte_eth_dev_count_avail();
  if (nb_ports == 0)
    rte_exit(EXIT_FAILURE, "No Ethernet ports - bye\n");

  if (port_pair_params != NULL) {
    if (check_port_pair_config(&l2fwd_enabled_port_mask) < 0)
      rte_exit(EXIT_FAILURE, "Invalid port pair config\n");
  }

  /* check port mask to possible port mask */
  if (l2fwd_enabled_port_mask & ~((1 << nb_ports) - 1))
    rte_exit(EXIT_FAILURE, "Invalid portmask; possible (0x%x)\n",
             (1 << nb_ports) - 1);

  /* reset l2fwd_dst_ports */
  for (portid = 0; portid < RTE_MAX_ETHPORTS; portid++)
    l2fwd_dst_ports[portid] = 0;
  last_port = 0;

  /* populate destination port details */
  if (port_pair_params != NULL) {
    uint16_t idx, p;

    for (idx = 0; idx < (nb_port_pair_params << 1); idx++) {
      p = idx & 1;
      portid = port_pair_params[idx >> 1].port[p];
      l2fwd_dst_ports[portid] = port_pair_params[idx >> 1].port[p ^ 1];
    }
  } else {
    RTE_ETH_FOREACH_DEV(portid) {
      /* skip ports that are not enabled */
      if ((l2fwd_enabled_port_mask & (1 << portid)) == 0)
        continue;

      if (nb_ports_in_mask % 2) {
        l2fwd_dst_ports[portid] = last_port;
        l2fwd_dst_ports[last_port] = portid;
      } else {
        last_port = portid;
      }

      nb_ports_in_mask++;
    }
    if (nb_ports_in_mask % 2) {
      printf("Notice: odd number of ports in portmask.\n");
      l2fwd_dst_ports[last_port] = last_port;
    }
  }

  rx_lcore_id = 0;
  qconf = NULL;

  /* Initialize the port/queue configuration of each logical core */
  RTE_ETH_FOREACH_DEV(portid) {
    /* skip ports that are not enabled */
    if ((l2fwd_enabled_port_mask & (1 << portid)) == 0)
      continue;

    /* get the lcore_id for this port */
    while (rte_lcore_is_enabled(rx_lcore_id) == 0 ||
           lcore_queue_conf[rx_lcore_id].n_rx_port ==
               l2fwd_rx_queue_per_lcore) {
      rx_lcore_id++;
      if (rx_lcore_id >= RTE_MAX_LCORE)
        rte_exit(EXIT_FAILURE, "Not enough cores\n");
    }

    if (qconf != &lcore_queue_conf[rx_lcore_id]) {
      /* Assigned a new logical core in the loop above. */
      qconf = &lcore_queue_conf[rx_lcore_id];
      nb_lcores++;
    }

    qconf->rx_port_list[qconf->n_rx_port] = portid;
    qconf->n_rx_port++;
    printf("Lcore %u: RX port %u TX port %u\n", rx_lcore_id, portid,
           l2fwd_dst_ports[portid]);
  }

  nb_mbufs = RTE_MAX(nb_ports * (nb_rxd + nb_txd + MAX_PKT_BURST +
                                 nb_lcores * MEMPOOL_CACHE_SIZE),
                     8192U);

  /* create the mbuf pool */
  l2fwd_pktmbuf_pool =
      rte_pktmbuf_pool_create("mbuf_pool", nb_mbufs, MEMPOOL_CACHE_SIZE, 0,
                              RTE_MBUF_DEFAULT_BUF_SIZE, rte_socket_id());
  if (l2fwd_pktmbuf_pool == NULL)
    rte_exit(EXIT_FAILURE, "Cannot init mbuf pool\n");

  /* Initialise each port */
  RTE_ETH_FOREACH_DEV(portid) {
    struct rte_eth_rxconf rxq_conf;
    struct rte_eth_txconf txq_conf;
    struct rte_eth_conf local_port_conf = port_conf;
    struct rte_eth_dev_info dev_info;

    /* skip ports that are not enabled */
    if ((l2fwd_enabled_port_mask & (1 << portid)) == 0) {
      printf("Skipping disabled port %u\n", portid);
      continue;
    }
    nb_ports_available++;

    /* init port */
    printf("Initializing port %u... ", portid);
    fflush(stdout);

    ret = rte_eth_dev_info_get(portid, &dev_info);
    if (ret != 0)
      rte_exit(EXIT_FAILURE, "Error during getting device (port %u) info: %s\n",
               portid, strerror(-ret));

    if (offload_ipv4_checksum && !(dev_info.tx_offload_capa & DEV_TX_OFFLOAD_IPV4_CKSUM))
      rte_exit(EXIT_FAILURE, "Device does not support IPv4 checksum offloading: port=%u\n",
               portid);

    if (dev_info.tx_offload_capa & DEV_TX_OFFLOAD_MBUF_FAST_FREE)
      local_port_conf.txmode.offloads |= DEV_TX_OFFLOAD_MBUF_FAST_FREE;
    ret = rte_eth_dev_configure(portid, 1, 1, &local_port_conf);
    if (ret < 0)
      rte_exit(EXIT_FAILURE, "Cannot configure device: err=%d, port=%u\n", ret,
               portid);

    ret = rte_eth_dev_adjust_nb_rx_tx_desc(portid, &nb_rxd, &nb_txd);
    if (ret < 0)
      rte_exit(EXIT_FAILURE,
               "Cannot adjust number of descriptors: err=%d, port=%u\n", ret,
               portid);

    ret = rte_eth_macaddr_get(portid, &l2fwd_ports_eth_addr[portid]);
    if (ret < 0)
      rte_exit(EXIT_FAILURE, "Cannot get MAC address: err=%d, port=%u\n", ret,
               portid);

    /* init one RX queue */
    fflush(stdout);
    rxq_conf = dev_info.default_rxconf;
    rxq_conf.offloads = local_port_conf.rxmode.offloads;
    ret =
        rte_eth_rx_queue_setup(portid, 0, nb_rxd, rte_eth_dev_socket_id(portid),
                               &rxq_conf, l2fwd_pktmbuf_pool);
    if (ret < 0)
      rte_exit(EXIT_FAILURE, "rte_eth_rx_queue_setup:err=%d, port=%u\n", ret,
               portid);

    /* init one TX queue on each port */
    fflush(stdout);
    txq_conf = dev_info.default_txconf;
    txq_conf.offloads = local_port_conf.txmode.offloads;
    ret = rte_eth_tx_queue_setup(portid, 0, nb_txd,
                                 rte_eth_dev_socket_id(portid), &txq_conf);
    if (ret < 0)
      rte_exit(EXIT_FAILURE, "rte_eth_tx_queue_setup:err=%d, port=%u\n", ret,
               portid);

    /* Initialize TX buffers */
    tx_buffer[portid] = (rte_eth_dev_tx_buffer *)rte_zmalloc_socket(
        "tx_buffer", RTE_ETH_TX_BUFFER_SIZE(MAX_PKT_BURST), 0,
        rte_eth_dev_socket_id(portid));
    if (tx_buffer[portid] == NULL)
      rte_exit(EXIT_FAILURE, "Cannot allocate buffer for tx on port %u\n",
               portid);

    rte_eth_tx_buffer_init(tx_buffer[portid], MAX_PKT_BURST);

    ret = rte_eth_tx_buffer_set_err_callback(tx_buffer[portid],
                                             rte_eth_tx_buffer_count_callback,
                                             &port_statistics[portid].dropped);
    if (ret < 0)
      rte_exit(EXIT_FAILURE,
               "Cannot set error callback for tx buffer on port %u\n", portid);

    ret = rte_eth_dev_set_ptypes(portid, RTE_PTYPE_UNKNOWN, NULL, 0);
    if (ret < 0)
      printf("Port %u, Failed to disable Ptype parsing\n", portid);
    /* Start device */
    ret = rte_eth_dev_start(portid);
    if (ret < 0)
      rte_exit(EXIT_FAILURE, "rte_eth_dev_start:err=%d, port=%u\n", ret,
               portid);

    printf("done: \n");

    ret = rte_eth_promiscuous_enable(portid);
    if (ret != 0)
      rte_exit(EXIT_FAILURE, "rte_eth_promiscuous_enable:err=%s, port=%u\n",
               rte_strerror(-ret), portid);

    printf("Port %u, MAC address: %02X:%02X:%02X:%02X:%02X:%02X\n\n", portid,
           l2fwd_ports_eth_addr[portid].addr_bytes[0],
           l2fwd_ports_eth_addr[portid].addr_bytes[1],
           l2fwd_ports_eth_addr[portid].addr_bytes[2],
           l2fwd_ports_eth_addr[portid].addr_bytes[3],
           l2fwd_ports_eth_addr[portid].addr_bytes[4],
           l2fwd_ports_eth_addr[portid].addr_bytes[5]);

    /* initialize port stats */
    memset(&port_statistics, 0, sizeof(port_statistics));
  }

  if (!nb_ports_available) {
    rte_exit(EXIT_FAILURE,
             "All available ports are disabled. Please set portmask.\n");
  }

  check_all_ports_link_status(l2fwd_enabled_port_mask);

  ret = 0;
  /* launch per-lcore init on every lcore */
  rte_eal_mp_remote_launch(l2fwd_launch_one_lcore, NULL, CALL_MAIN);
  RTE_LCORE_FOREACH_WORKER(lcore_id) {
    if (rte_eal_wait_lcore(lcore_id) < 0) {
      ret = -1;
      break;
    }
  }

  RTE_ETH_FOREACH_DEV(portid) {
    if ((l2fwd_enabled_port_mask & (1 << portid)) == 0)
      continue;
    printf("Closing port %d...", portid);
    ret = rte_eth_dev_stop(portid);
    if (ret != 0)
      printf("rte_eth_dev_stop: err=%d, port=%d\n", ret, portid);
    rte_eth_dev_close(portid);
    printf(" Done\n");
  }

  /* clean up the EAL */
  rte_eal_cleanup();
  printf("Bye...\n");

#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)
  printf("throughput, %s, %lu, %lu\n", TOSTRING(NAME), BATCH_SIZE,
         last_throughput);
  printf("latency, %s, %lu, %lu\n", TOSTRING(NAME), BATCH_SIZE, last_latency);

  return ret;
}
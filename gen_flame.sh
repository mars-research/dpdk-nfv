#!/bin/sh
sperf script -i $1_perf.data | sudo FlameGraph/stackcollapse-perf.pl | FlameGraph/flamegraph.pl > $1_perf.svg 
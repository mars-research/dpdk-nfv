# dpdk-nfv

## Running the experiments

```
./build/nfv-nofxsave-8 --vdev=net_tap0,iface=nfv0 -- --portmask 0x1
```

## Running DPDK Pktgen

```
sudo $(which pktgen) -c fffff -- -m '[1:2].0' -f pktgen-config.txt
```

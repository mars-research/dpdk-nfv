# dpdk-nfv

## Running the experiments

```
./build/nfv-nofxsave-8 --vdev=net_tap0,iface=nfv0 -- --portmask 0x1
```

## Running DPDK Pktgen

```
sudo $(which pktgen) -c fffff -- -m '[1:2].0' -f pktgen-config.txt
```


## Setup DPDK

```
sudo vim /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on iommu=pt"
sudo update-grub
sudo $(which dpdk-hugepages.py) -p 1G --setup 2G
sudo $(which dpdk-devbind.py) --bind=vfio-pci 0000:5e:00.0 --force
```
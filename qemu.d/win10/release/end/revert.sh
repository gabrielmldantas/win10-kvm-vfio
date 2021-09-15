#!/bin/bash
# Debug
set -x

# Load variables
source /etc/libvirt/hooks/kvm.conf

# unload vfio-pci
modprobe --remove --force vfio_pci
modprobe --remove --force vfio_iommu_type1
modprobe --remove --force vfio

# Rebind PCI devs
for pci_dev in "${VIRSH_PCI_DEVS[@]}"
do
	virsh nodedev-reattach "$pci_dev"
done

# rebind VTconsoles
echo 1 | tee /sys/class/vtconsole/vtcon*/bind >/dev/null

# Reload modules
for m in "${MODULES[@]}"
do
	modprobe "$m"
done

# switch back to schedutil governor
cpupower frequency-set -g schedutil

# Restart bluetooth service
systemctl start bluetooth.service

# Restart Display service
systemctl start display-manager.service


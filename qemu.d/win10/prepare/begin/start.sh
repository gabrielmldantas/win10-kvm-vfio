#!/bin/bash
# Helpful to read output when debugging
set -x

# load variables we defined
source /etc/libvirt/hooks/kvm.conf

# Terminate sessions safely
for s in $(loginctl --no-legend list-sessions | cut -d' ' -f1)
do
	d="$(loginctl show-session "$s" --property=Desktop --value)"
	[[ -n "$d" ]] && loginctl terminate-session "$s"
done

# Stop display manager
systemctl stop display-manager.service

# Stop all pipewire instances
killall pipewire

# Unbind VTconsoles
echo 0 | tee /sys/class/vtconsole/vtcon*/bind >/dev/null

# Unload the modules
# Retry until unload succeeds
for m in "${MODULES[@]}"
do
	ret=0
	for _ in $(seq 4)
	do
		ret=0
		modprobe --remove --force "$m" || ret=1
		lsmod | grep -q -- '\b'"$m"'\b' && ret=1
		[[ $ret -eq 0 ]] && break
		sleep 2
	done
	[[ $ret -ne 0 ]] && exit 1
done

# Detach the pci devices
for pci_dev in "${VIRSH_PCI_DEVS[@]}"
do
	virsh nodedev-detach "$pci_dev"
done

# load vfio
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1

# Switch to performance governor
cpupower frequency-set -g performance


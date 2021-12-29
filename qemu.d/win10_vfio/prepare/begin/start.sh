#!/bin/bash

# Terminate sessions safely
for s in $(loginctl --no-legend list-sessions | cut -d' ' -f1)
do
	d="$(loginctl show-session "$s" --property=Desktop --value)"
	[[ -n "$d" ]] && loginctl terminate-session "$s"
done

# Stop display manager
systemctl stop display-manager.service

# Stop bluetooth service
systemctl stop bluetooth.service

# Stop all pipewire instances
pgrep pipewire | xargs kill

# Switch to performance governor
cpupower frequency-set -g performance

modprobe --remove --force amdgpu

modprobe vfio_pci
modprobe vfio_iommu_type1
modprobe vfio

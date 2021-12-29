#!/bin/bash

modprobe --remove --force vfio_pci
modprobe --remove --force vfio_iommu_type1
modprobe --remove --force vfio

modprobe amdgpu

# switch back to schedutil governor
cpupower frequency-set -g schedutil

# Restart bluetooth service
systemctl start bluetooth.service

# Restart Display service
systemctl start display-manager.service


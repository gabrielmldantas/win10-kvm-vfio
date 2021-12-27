#!/bin/bash

# switch back to schedutil governor
cpupower frequency-set -g schedutil

# Restart bluetooth service
systemctl start bluetooth.service

# Restart Display service
systemctl start display-manager.service


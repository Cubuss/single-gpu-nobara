#!/bin/bash
# Helpful to read output when debugging
set -x

# Stop display manager (KDE specific)
systemctl stop sddm.service

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind

# Unbind EFI-Framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

sleep 5

# Unload AMD drivers
modprobe -r amdgpu

# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_01_00_0
virsh nodedev-detach pci_0000_01_00_1

# Load VFIO kernel module
modprobe vfio-pci

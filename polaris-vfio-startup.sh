#!/bin/bash
# Helpful to read output when debugging
set -x

# Stop display manager
#systemctl stop x11vnc.service
systemctl stop sddm.service

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
#echo 0 > /sys/class/vtconsole/vtcon1/bind


# Unbind EFI-Framebuffer
#echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

sleep 5

# Unload AMD drivers
modprobe -r amdgpu

#/bin/polaris-unbind-and-reset.sh 0000:01:00.0
#echo -n "0000:01:00.0" > /sys/bus/pci/drivers/amdgpu/unbind || echo "Failed to unbind gpu from amdgpu"
#echo -n "0000:01:00.1" > /sys/bus/pci/drivers/snd_hda_intel/unbind || echo "Failed to unbind hdmi audio in gpu"


# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_01_00_0
virsh nodedev-detach pci_0000_01_00_1

# Load VFIO kernel module
modprobe vfio-pci
#tell vfio-pci that it takes care of gpu
#echo -n "1002 67df" > /sys/bus/pci/drivers/vfio-pci/new_id
#echo -n "1002 aaf0" > /sys/bus/pci/drivers/vfio-pci/new_id



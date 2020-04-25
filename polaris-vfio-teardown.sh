#!/bin/bash
set -x

# Unload VFIO-PCI Kernel Driver
modprobe -r vfio-pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# Re-Bind GPU to AMD Driver
virsh nodedev-reattach pci_0000_01_00_1
virsh nodedev-reattach pci_0000_01_00_0

# Rebind VT consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
#echo 1 > /sys/class/vtconsole/vtcon1/bind

# Re-Bind EFI-Framebuffer
#echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

#Load amd driver
modprobe amdgpu

# Restart Display Manager
systemctl start sddm.service
#systemctl start x11vnc.service

#echo -n 0000:01:00.0 > /sys/bus/pci/drivers/vfio-pci/unbind || echo "Failed to unbind gpu from vfio-pci"
#echo -n 0000:01:00.1 > /sys/bus/pci/drivers/vfio-pci/unbind || echo "Failed to unbind gpu-audio from vfio-pci"

#echo -n 1002 67df > /sys/bus/pci/drivers/vfio-pci/remove_id
#echo -n 1002 aaf0 > /sys/bus/pci/drivers/vfio-pci/remove_id

#modprobe -r vfio-pci

#echo -n 0000:01:00.0 > /sys/bus/pci/drivers/amdgpu/bind || echo "Failed to bind amdgpu"
#echo -n 0000:01:00.1 > /sys/bus/pci/drivers/snd_hda_intel/bind || echo "Failed to bind amd hdmi audio"

#systemctl isolate graphical.target
#systemctl suspend

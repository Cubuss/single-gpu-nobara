#!/bin/bash
set -x

echo "Beginning of teardown!"

# Unload VFIO-PCI Kernel Driver
modprobe -r vfio-pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# Re-Bind GPU to AMD Driver
virsh nodedev-reattach pci_0000_01_00_1
virsh nodedev-reattach pci_0000_01_00_0

# Rebind VT consoles
if test -e "/sys/class/vtconsole/vtcon0/bind" ; then
    echo 1 > /sys/class/vtconsole/vtcon0/bind
fi
if test -e "/sys/class/vtconsole/vtcon1/bind" ; then
    echo 1 > /sys/class/vtconsole/vtcon1/bind
fi

# Hack that magically makes nvidia gpus work :)
if command -v nvidia-xconfig ; then
    nvidia-xconfig --query-gpu-info > /dev/null 2>&1
fi

# Re-Bind EFI-Framebuffer
if test -e "/sys/bus/platform/drivers/efi-framebuffer/bind" ; then
    echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind
else
    echo "Could not find framebuffer to bind!"
fi

#Load amd driver
input="/tmp/vfio-loaded-gpu-modules"
while read gpuModule; do
  modprobe "$gpuModule"
done < "$input"

# Restart Display Manager
input="/tmp/vfio-store-display-manager"
while read displayManager; do
  systemctl start "$displayManager"
done < "$input"

echo "End of teardown!"

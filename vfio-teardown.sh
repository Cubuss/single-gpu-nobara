#!/bin/bash
set -x

echo "Beginning of teardown!"

# Unload VFIO-PCI Kernel Driver
modprobe -r vfio-pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# Re-Bind GPU to AMD Driver
input="/tmp/vfio-virsh-ids"
while read virshId; do
  virsh nodedev-reattach "$virshId"
done < "$input"

# Rebind VT consoles (adapted from https://www.kernel.org/doc/Documentation/fb/fbcon.txt)
input="/tmp/vfio-bound-consoles"
while read consoleNumber; do
  if test -x /sys/class/vtconsole/vtcon${consoleNumber}; then
      if [ `cat /sys/class/vtconsole/vtcon${consoleNumber}/name | grep -c "frame buffer"` \
           = 1 ]; then
    echo "Rebinding console ${consoleNumber}"
	  echo 1 > /sys/class/vtconsole/vtcon${consoleNumber}/bind
      fi
  fi
done < "$input"

# Hack that magically makes nvidia gpus work :)
if command -v nvidia-xconfig ; then
    nvidia-xconfig --query-gpu-info > /dev/null 2>&1
fi

# According to kernel documentation (https://www.kernel.org/doc/Documentation/fb/fbcon.txt), 
# specifically unbinding efi-framebuffer is not necessary after all consoles
# are unbound (and often times harmful in my experience), so it was omitted here
# I leave it here for reference in case anyone needs it.

# Re-Bind EFI-Framebuffer
# if test -e "/sys/bus/platform/drivers/efi-framebuffer/bind" ; then
#     echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind
# else
#     echo "Could not find framebuffer to bind!"
# fi

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

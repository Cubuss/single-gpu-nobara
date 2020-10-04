#!/bin/bash
# Helpful to read output when debugging
set -x

long_delay=10
medium_delay=5
short_delay=1
echo "Beginning of startup!"

# Stop currently running display manager
if test -e "/tmp/vfio-store-display-manager" ; then
    rm -f /tmp/vfio-store-display-manager
fi
if systemctl is-active --quiet sddm.service ; then
    echo sddm.service >> /tmp/vfio-store-display-manager
    systemctl stop sddm.service
fi
while systemctl is-active --quiet sddm.service ; do
    sleep "${short_delay}"
done
if systemctl is-active --quiet gdm.service ; then
    echo gdm.service >> /tmp/vfio-store-display-manager
    systemctl stop gdm.service
fi
if systemctl is-active --quiet lightdm.service ; then
    echo lightdm.service >> /tmp/vfio-store-display-manager
    systemctl stop lightdm.service
fi
if systemctl is-active --quiet lxdm.service ; then
    echo lxdm.service >> /tmp/vfio-store-display-manager
    systemctl stop lxdm.service
fi
if systemctl is-active --quiet xdm.service ; then
    echo xdm.service >> /tmp/vfio-store-display-manager
    systemctl stop xdm.service
fi

# Unbind VTconsoles if currently bound
if test -e "/sys/class/vtconsole/vtcon0/bind" ; then
    echo 0 > /sys/class/vtconsole/vtcon0/bind
    sleep "${long_delay}"
fi
if test -e "/sys/class/vtconsole/vtcon1/bind" ; then
    echo 0 > /sys/class/vtconsole/vtcon1/bind
    sleep "${long_delay}"
fi

#Unbind EFI-Framebuffer if currently bound
if test -e "/sys/bus/platform/drivers/efi-framebuffer/unbind" ; then
    echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
    sleep "${medium_delay}"
else
    echo "Could not find framebuffer to unload!"
fi

# Unload loaded GPU drivers
if test -e "/tmp/vfio-loaded-gpu-modules" ; then
    rm -f /tmp/vfio-loaded-gpu-modules
fi
if lsmod | grep amdgpu &> /dev/null ; then
    modprobe -r amdgpu
    echo amdgpu >> /tmp/vfio-loaded-gpu-modules
fi
while lsmod | grep amdgpu &> /dev/null ; do
    sleep 1
done
if lsmod | grep nvidia_drm &> /dev/null ; then
    modprobe -r nvidia_drm
    echo nvidia_drm >> /tmp/vfio-loaded-gpu-modules
fi
if lsmod | grep nvidia_modeset &> /dev/null ; then
    modprobe -r nvidia_modeset
    echo nvidia_modeset >> /tmp/vfio-loaded-gpu-modules
fi
if lsmod | grep nvidia_uvm &> /dev/null ; then
    modprobe -r nvidia_uvm
    echo nvidia_uvm >> /tmp/vfio-loaded-gpu-modules
fi
if lsmod | grep nvidia &> /dev/null ; then
    modprobe -r nvidia
    echo nvidia >> /tmp/vfio-loaded-gpu-modules
fi
if lsmod | grep ipmi_devintf &> /dev/null ; then
    modprobe -r ipmi_devintf
    echo ipmi_devintf >> /tmp/vfio-loaded-gpu-modules
fi


# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_01_00_0
virsh nodedev-detach pci_0000_01_00_1

# Load VFIO kernel module
modprobe vfio-pci

echo "End of startup!"
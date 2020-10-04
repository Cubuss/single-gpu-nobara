#!/bin/bash
# Helpful to read output when debugging
set -x

long_delay=10
medium_delay=5
short_delay=1
echo "Beginning of startup!"

function stop_display_manager_if_running {
    if systemctl is-active --quiet $1 ; then
        echo $1 >> /tmp/vfio-store-display-manager
        systemctl stop $1
    fi

    while systemctl is-active --quiet $1 ; do
        sleep "${short_delay}"
    done
}

function unload_module_if_loaded {
    if lsmod | grep $1 &> /dev/null ; then
    modprobe -r $1
    echo $1 >> /tmp/vfio-loaded-gpu-modules
    fi
    while lsmod | grep $1 &> /dev/null ; do
        sleep 1
    done
}

# Stop currently running display manager
if test -e "/tmp/vfio-store-display-manager" ; then
    rm -f /tmp/vfio-store-display-manager
fi
stop_display_manager_if_running sddm.service
stop_display_manager_if_running gdm.service
stop_display_manager_if_running lightdm.service
stop_display_manager_if_running lxdm.service
stop_display_manager_if_running xdm.service

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

unload_module_if_loaded amdgpu
unload_module_if_loaded nvidia_drm
unload_module_if_loaded nvidia_modeset
unload_module_if_loaded nvidia_uvm
unload_module_if_loaded nvidia
unload_module_if_loaded ipmi_devintf


# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_01_00_0
virsh nodedev-detach pci_0000_01_00_1

# Load VFIO kernel module
modprobe vfio-pci

echo "End of startup!"
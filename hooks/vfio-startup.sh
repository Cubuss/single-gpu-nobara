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

function get_virsh_id {
    python -c "print('pci_0000_'+'$1'.split(':')[0] + '_' + '$1'.split(':')[1].split('.')[0] + '_' + '$1'.split(':')[1].split('.')[1])"
}

function get_pci_id_from_device_id {
    lspci -nn | grep $1 | awk '{print $1}'
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
stop_display_manager_if_running mdm.service
stop_display_manager_if_running display-manager.service


# Unbind VTconsoles if currently bound (adapted from https://www.kernel.org/doc/Documentation/fb/fbcon.txt)
if test -e "/tmp/vfio-bound-consoles" ; then
    rm -f /tmp/vfio-bound-consoles
fi
for (( i = 0; i < 16; i++))
do
  if test -x /sys/class/vtconsole/vtcon${i}; then
      if [ `cat /sys/class/vtconsole/vtcon${i}/name | grep -c "frame buffer"` \
           = 1 ]; then
	       echo 0 > /sys/class/vtconsole/vtcon${i}/bind
           echo "Unbinding console ${i}"
           echo $i >> /tmp/vfio-bound-consoles
      fi
  fi
done

# According to kernel documentation (https://www.kernel.org/doc/Documentation/fb/fbcon.txt), 
# specifically unbinding efi-framebuffer is not necessary after all consoles
# are unbound (and often times harmful in my experience), so it was omitted here
# I leave it here for reference in case anyone needs it.

#Unbind EFI-Framebuffer if currently bound
# if test -e "/sys/bus/platform/drivers/efi-framebuffer/unbind" ; then
#     echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
# else
#     echo "Could not find framebuffer to unload!"


sleep "${long_delay}"

# Unload loaded GPU drivers
if test -e "/tmp/vfio-loaded-gpu-modules" ; then
    rm -f /tmp/vfio-loaded-gpu-modules
fi

unload_module_if_loaded amdgpu-pro
unload_module_if_loaded amdgpu
unload_module_if_loaded nvidia_drm
unload_module_if_loaded nvidia_modeset
unload_module_if_loaded nvidia_uvm
unload_module_if_loaded nvidia
unload_module_if_loaded ipmi_devintf
unload_module_if_loaded nouveau
unload_module_if_loaded i915

# Unbind the GPU from display driver
if test -e "/tmp/vfio-virsh-ids" ; then
    rm -f /tmp/vfio-virsh-ids
fi

gpu_device_id=$(modprobe -c vfio-pci | grep 'options vfio_pci ids' | cut -d '=' -f2 | cut -d ',' -f 1)
gpu_audio_device_id=$(modprobe -c vfio-pci | grep 'options vfio_pci ids' | cut -d '=' -f2 | cut -d ',' -f 2)
gpu_pci_id=$(get_pci_id_from_device_id ${gpu_device_id})
gpu_audio_pci_id=$(get_pci_id_from_device_id ${gpu_audio_device_id})
virsh_gpu_id=$(get_virsh_id ${gpu_pci_id})
virsh_gpu_audio_id=$(get_virsh_id ${gpu_audio_pci_id})
echo ${virsh_gpu_audio_id} >> /tmp/vfio-virsh-ids
echo ${virsh_gpu_id} >> /tmp/vfio-virsh-ids

virsh nodedev-detach "${virsh_gpu_id}"
virsh nodedev-detach "${virsh_gpu_audio_id}"

# Load VFIO kernel module
modprobe vfio-pci

echo "End of startup!"

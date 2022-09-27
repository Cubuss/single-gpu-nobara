  GNU nano 6.0                                                                    vfio-startup.sh                                                                               
# Helpful to read output when debugging
set -x
 

systemctl stop gdm
killall gdm-x-session
 

echo 0 > /sys/class/vtconsole/vtcon0/bind
#echo 0 > /sys/class/vtconsole/vtcon1/bind
 

echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
 
sleep 2
 

modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r nvidia_uvm
modprobe -r nvidia
modprobe -r ipmi_devintf
 
 
 
 
# change pci_0000_08_00_0 to your GPU and AUDIO ID from IOMU script
virsh nodedev-detach pci_0000_08_00_0  
virsh nodedev-detach pci_0000_08_00_1
 

modprobe vfio-pci


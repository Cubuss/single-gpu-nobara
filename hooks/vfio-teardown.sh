  GNU nano 6.0                                                                    vfio-teardown.sh                                                                              
!/bin/bash
set -x

modprobe -r vfio-pci
modprobe -r vfio_iommu_type1
modprobe -r vfio
 
# change pci_0000_08_00_0 to your GPU and Audio PCI id from IOMMU group script
virsh nodedev-reattach pci_0000_08_00_0
virsh nodedev-reattach pci_0000_08_00_1
 

echo 1 > /sys/class/vtconsole/vtcon0/bind
nvidia-xconfig --query-gpu-info > /dev/null 2>&1
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind
 

modprobe nvidia_drm
modprobe nvidia_modeset
modprobe nvidia_uvm
modprobe nvidia
modprobe ipmi_devintf
modprobe ipmi_msghandler
 

systemctl start gdm




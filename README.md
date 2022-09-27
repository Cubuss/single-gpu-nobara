1) Make sure virtualisation is enabled etc in bios 

AMD:

IOMMU = enabled
NX mode = enabled
SVM mode = enabled

INTEL:

VT-D = Enabled VT-X = Enabled

2) sudo nano /etc/default/grub 

If you have AMD:  amd_iommu=on iommu=pt 
If you have Intel: intel_iommu=on iommu=pt 
add to GRUB_CMDLINE_LINUX="xxxx" line

3) sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg   
4) reboot 
5) run this script to see if IOMMU groups are valid:

#!/bin/bash
shopt -s nullglob
for g in /sys/kernel/iommu_groups/*; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;

6) sudo dnf install @virtualization
7)sudo nano /etc/libvirt/libvirtd.conf  

uncomment following lines: 

    unix_sock_group = "libvirt"
    unix_sock_rw_perms = "0770"
    
8) add the following to end of the conf file for to make logs to troubleshoot
log_filters="1:qemu"
log_outputs="1:file:/var/log/libvirt/libvirtd.log"

9) run following commands:
sudo usermod -a -G libvirt $(whoami)
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

10) verify:
sudo groups $(whoami)  

output will be : username libvirt etc...


11) sudo nano /etc/libvirt/qemu.conf
#user = "root" to user = "your username"
#group = "root" to group = "your username"

save then : sudo systemctl restart libvirtd

12) sudo virsh net-autostart default
    sudo virsh net-start default

13) Download latest stable https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md (Stable virtio-win ISO)
and windows 11 iso 

14) Run virtual machine manager 
click plus for new virtual machine (Make sure its named win10)
local install media iso 
select win11 iso 
select desired storage:
check customise configuration before install
click add hardware bottom left 
select TPM > Type emulated CRB v2.0
CPU options select Q35 as chipset FOr UEFI firmware choose 
UEFI x86_64: /usr/share/edk2/ovmf/OVMF_CODE.secboot.fd
Set the max Logical Host CPU's and choose Topology
Set Memory 8GB or more
VirtIO disk set to Virtio
Option cache mode as writeback
click add hardware select storage select CD
make sure both WIN11 and virtio ISO are added 

Boot vm and install windows 11 if it asks for drivers you can select browse and choose virtio drivers to install 
go to amd64 folder > w11 


15) Dump vbios and edit full guide :
https://gitlab.com/risingprismtv/single-gpu-passthrough/-/wikis/6)-Preparation-and-placing-of-ROM-file

16) Download this repo :
edit both vfio-startup.sh and vfio-teardown.sh scripts in hooks folder to your PCI gpu and audio ids you can get from the iommu script

![image](https://user-images.githubusercontent.com/9220880/192648015-46d3eb8b-a383-4d13-8c13-1a57059fb858.png)


![image](https://user-images.githubusercontent.com/9220880/192647882-9a16002d-50b7-47c4-bc74-199964addadf.png)



17)Open vm add hardware > PCI host device and choose both your GPU and AUDIO (ones you added to the script )

18) if you have nvidia GPU :
sudo virsh edit win10


add or edit the following lines:

  </os>
  <features>
    <acpi/>
    <apic/>
    <hyperv>
      <relaxed state='on'/>
      <vapic state='on'/>
      <spinlocks state='on' retries='8191'/>
      <vendor_id state='on' value='123456789123'/>
    </hyperv>
    <kvm>
      <hidden state='on'/>
    </kvm>
    <vmport state='off'/>
    <ioapic driver='kvm'/>


for AMD CPU:

# </features>
  <cpu mode='host-passthrough' check='none'>
    <topology sockets='1' cores='6' threads='2'/>
    <feature policy='require' name='topoext'/>
  </cpu>

for intel :
</features>
  <cpu mode='host-passthrough' check='none'>
    <topology sockets='1' cores='6' threads='2'/>
    <feature policy='disable' name='smep'/>
  </cpu>
#

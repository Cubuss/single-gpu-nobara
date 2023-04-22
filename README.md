1) Make sure virtualisation is enabled etc in bios 

AMD:
```
IOMMU = enabled
NX mode = enabled
SVM mode = enabled
```
INTEL:
```
VT-D = Enabled VT-X = Enabled
```
2) ``sudo nano /etc/default/grub ``

If you have AMD:  ``amd_iommu=on iommu=pt`` 
If you have Intel: ``intel_iommu=on iommu=pt ``
add to GRUB_CMDLINE_LINUX="xxxx" line 

example:

```GRUB_DEFAULT='saved'
GRUB_DISABLE_RECOVERY='true'
GRUB_DISABLE_SUBMENU='true'
GRUB_ENABLE_BLSCFG='true'
GRUB_TERMINAL_OUTPUT='console'
GRUB_TIMEOUT='5'
GRUB_CMDLINE_LINUX_DEFAULT='amd_iommu=on iommu=pt quiet video=efifb:off splash resume=UUID=988abac8-e687-4b47-9056-9d9d073503e9'
GRUB_DISTRIBUTOR='Nobara Linux'
GRUB_CMDLINE_LINUX="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1"

```



3)`` sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg   ``

4) reboot 

6) run this script to see if IOMMU groups are valid:
```
#!/bin/bash
shopt -s nullglob
for g in /sys/kernel/iommu_groups/*; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```
6) ``sudo dnf install @virtualization``
7) ``sudo nano /etc/libvirt/libvirtd.conf `` 

uncomment following lines: 

    unix_sock_group = "libvirt"
    unix_sock_rw_perms = "0770"
    
8) add the following to end of the conf file for to make logs to troubleshoot
```log_filters="1:qemu"
log_outputs="1:file:/var/log/libvirt/libvirtd.log"
```
9) run following commands:
``sudo usermod -a -G libvirt $(whoami)``
``sudo systemctl start libvirtd``
``sudo systemctl enable libvirtd``

10) verify:
``sudo groups $(whoami) `` 

output will be :`` username libvirt etc``


11) ``sudo nano /etc/libvirt/qemu.conf``
change following:
```
#user = "root" to user = "your username"
#group = "root" to group = "your username"
```
save then :`` sudo systemctl restart libvirtd``

12) ``sudo virsh net-autostart default``
   `` sudo virsh net-start default``

13) Download latest stable https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md (Stable virtio-win ISO)
and windows 11 iso 


MAKE SURE TO DOWNGRADE OVMF ELSE WINDOWS INSTALLER WONT BOOT ON LATEST NOBARA 37
DOWNGRADE ovmf:

```sudo dnf downgrade edk2-ovmf```

<details><summary>14) Click Here for VM SETUP</summary>
<p>

#### Run virtual machine manager and do the following:

```Run virtual machine manager
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
```

</p>
</details>



Boot vm and install windows 11 if it asks for drivers you can select browse and choose virtio drivers to install 
go to amd64 folder > w11 


15) Dump vbios and edit full guide :
https://gitlab.com/risingprismtv/single-gpu-passthrough/-/wikis/6)-Preparation-and-placing-of-ROM-file


16)Open vm add hardware > PCI host device and choose both your GPU and AUDIO (ones you added to the script )
 for your GPU add <rom file="/var/lib/libvirt/vbios/yourromfilename.rom"/> to the xml tab in virtual manager
https://imgur.com/a/XT6VDeG

add keyboard and mouse via > add hardware > usb device. 
Remove spice / qxl stuff in VM

17)  Download this repo : edit both vfio-startup.sh and vfio-teardown.sh scripts in hooks folder to your PCI gpu and audio ids you can get from the iommu 



![image](https://user-images.githubusercontent.com/9220880/192649503-a3fe2084-932a-4787-8a1a-15f1b6a8f8a9.png)


![image](https://user-images.githubusercontent.com/9220880/192649528-7003ab27-0921-4d02-afc2-991141246241.png)



 add this line to the XML in your virutal manager PCI GPU tab 
 
``<rom file='/var/lib/libvirt/vbios/<romfile>.rom'/> ``

![image](https://user-images.githubusercontent.com/9220880/192890977-68336167-9c31-4e7d-b66a-e119dac61cf5.png)

(Change GP102.ROM To your rom file name)



18) if you have nvidia GPU :
``sudo virsh edit win10``


add or edit the following lines:
```
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
```
for AMD CPU:
 ```
</features>
  <cpu mode='host-passthrough' check='none'>
    <topology sockets='1' cores='6' threads='2'/>
    <feature policy='require' name='topoext'/>
  </cpu>
```

for intel 

```
</features>
  <cpu mode='host-passthrough' check='none'>
    <topology sockets='1' cores='6' threads='2'/>
    <feature policy='disable' name='smep'/>
  </cpu>
```

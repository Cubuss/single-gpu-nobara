edit both vfio-startup.sh and vfio-teardown.sh scripts in hooks folder to your PCI gpu and audio ids you can get from 

#!/bin/bash
shopt -s nullglob
for g in /sys/kernel/iommu_groups/*; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done; 



then install running install_hooks.sh as sudo

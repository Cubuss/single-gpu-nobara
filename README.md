edit both vfio-startup.sh and vfio-teardown.sh scripts in hooks folder to your PCI gpu and audio ids you can get from 

#!/bin/bash
shopt -s nullglob
for g in /sys/kernel/iommu_groups/*; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done; 

![image](https://user-images.githubusercontent.com/9220880/192647899-aa2ef3f6-9cf0-47e1-a4d5-ba2b09237aad.png)


![image](https://user-images.githubusercontent.com/9220880/192647882-9a16002d-50b7-47c4-bc74-199964addadf.png)

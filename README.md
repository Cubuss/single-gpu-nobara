edit both vfio-startup.sh and vfio-teardown.sh scripts in hooks folder to your PCI gpu and audio ids you can get from 

#!/bin/bash
shopt -s nullglob
for g in /sys/kernel/iommu_groups/*; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done; 

![image](https://user-images.githubusercontent.com/9220880/192648015-46d3eb8b-a383-4d13-8c13-1a57059fb858.png)



![image](https://user-images.githubusercontent.com/9220880/192647882-9a16002d-50b7-47c4-bc74-199964addadf.png)

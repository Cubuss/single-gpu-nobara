#!/bin/bash

dnf install @virtualization

function append_to_grub_cmdline {
    if tail -n 1 /etc/default/grub | grep 'enable iommu support' ; then
        # Remove old grub cmdline declaration if exists
        sed '$d' /etc/default/grub > /etc/default/grub
    fi
    echo "GRUB_CMDLINE_LINUX+=' ${1}' # enable iommu support" >> /etc/default/grub
}

function get_gpus {
    lspci -nn | grep VGA
}

function prompt_gpu_choice {
echo "Choose from the following gpus to pass through to your VM:"
IFS='
'
i=1
while read line; 
do 
    if [ $i = 1 ] ;
    then
        echo "$i (default) $line"
    else
        echo "$i $line"
    fi
    i=$((i+1)) 
done << EOF
$(get_gpus)
EOF
}

function get_gpu_choice_input {
    read -t 10 -p "Enter your choice here (default taken after 10 seconds): " ;
    if [ -z $REPLY ] ; then
        REPLY="1"
    fi

    gpu_choice=${REPLY}
}

function validate_gpu_choice {
    re='^[0-9]+$'
    if ! [[ ${gpu_choice} =~ ${re} ]] ; then
        echo "invalid choice ${gpu_choice}"
        get_gpu_choice_input
        validate_gpu_choice
    else
        if [ ${gpu_choice} -gt ${gpu_count} ] ; then
            echo "invalid choice ${gpu_choice}"
            get_gpu_choice_input
            validate_gpu_choice
        fi
    fi
}

function get_device_ids {
    gpu_device_id=$(lspci -nn | grep VGA | grep ${gpu_choice} | cut -d '[' -f 5 | cut -d ']' -f 1)
    gpu_audio_device_id=$(lspci -nn | grep -A 1 ${chosen_gpu_id} | sed -n 2p | cut -d '[' -f 5 | cut -d ']' -f 1 )
}

if lscpu | cut -d ':' -f 2 | awk 'FNR==11 {print $1}' | grep -i intel ; then
    append_to_grub_cmdline 'intel_iommu=on iommu=pt'
else
    if lscpu | cut -d ':' -f 2 | awk 'FNR==11 {print $1}' | grep -i amd ; then
        append_to_grub_cmdline 'amd_iommu=on iommu=pt'
    else
        echo "CPU not recognized"
        exit 1
    fi
fi

grub2-mkconfig -o /etc/grub2-efi.cfg

gpu_count=$(get_gpus | wc -l)
prompt_gpu_choice
get_gpu_choice_input
validate_gpu_choice
get_device_ids

echo "Passing through the following devices (${gpu_device_id}, ${gpu_audio_device_id}) :" 
echo "GPU: " "$(lspci -nn | grep ${gpu_device_id})" 
echo "GPU Audio: " "$(lspci -nn | grep ${gpu_audio_device_id})"

echo "options vfio-pci ids=${gpu_device_id},${gpu_audio_device_id}" > /etc/modprobe.d/vfio.conf
echo "options vfio-pci disable_vga=1" >> /etc/modprobe.d/vfio.conf

echo 'add_drivers+=" vfio vfio_iommu_type1 vfio_pci "' > /etc/dracut.conf.d/vfio.conf
dracut -f
# Single GPU Passthrough Scripts

Scripts for passing a single GPU from a Linux host to a Windows VM and back.

1. Change the VM name in qemu if not already win10
2. Run the install_hooks.sh script as root

Note the display manager should be detected automatically. If you are using an unsupported display manager that is not listed in the hooks/vfio-startup.sh script, feel free to contact us on the Discord server and we shall add your display manager.

Most of the source code is located in this repository. However, most executable files without an extension are compiled from this repo: https://gitlab.com/decisivedove/single-gpu-passthrough-automation

To setup the hooks, simply run sudo ./install_hooks.sh. To setup boot kernel parameters, run sudo ./setup_kernel_parameters.

If using startx, add a line `killall -u user_name` to qemu/vfio-startup.sh script towards the beginning and you can add a line to vfio-teardown.sh to start your window manager/ desktop environment again. Don't just add startx because it will be run as root. Instead add `su -s /bin/bash -c "/usr/bin/startx" -g username username` replacing username with your username to the end of the vfio-teardown.sh script.

For suggestions or support, join us on Discord at: https://discord.gg/bh4maVc


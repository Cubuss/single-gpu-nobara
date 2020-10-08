#!/bin/sh

mv /etc/libvirt/hooks/qemu /etc/libvirt/hooks/qemu_last_backup
mv /bin/vfio-startup.sh /bin/vfio-startup.sh.bkp
mv /bin/vfio-teardown.sh /bin/vfio-teardown.sh.bkp

cp vfio-startup.sh /bin/vfio-startup.sh
cp vfio-teardown.sh /bin/vfio-teardown.sh
cp qemu /etc/libvirt/hooks/qemu

chmod +x /bin/vfio-startup.sh
chmod +x /bin/vfio-teardonw/sh
chmod +x /etc/libvirt/hooks/qemu

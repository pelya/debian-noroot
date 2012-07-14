#!/bin/sh

echo "mount -t proc none /proc"
echo "mount -t sysfs none /sys"
echo "dhclient eth0"
echo "apt-get install fakeroot fakechroot xfonts-base tightvncserver synaptic busybox-static putty xfce4-panel xfce4-session xfce4-utils xfdesktop4 xfwm4 gimp"

qemu-system-arm -M versatilepb -cpu cortex-a8 -hda rootfs-gimp-lenny.img -m 256 -kernel vmlinuz -append 'rootwait root=/dev/sda init=/bin/sh rw'

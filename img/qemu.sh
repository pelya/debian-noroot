#!/bin/sh

echo "Now run inside qemu window:"
echo "./qemu-install.sh"

qemu-system-arm -M versatilepb -cpu cortex-a8 -hda rootfs-gimp-lenny.img -m 256 -kernel vmlinuz -append 'rootwait root=/dev/sda init=/bin/sh rw'

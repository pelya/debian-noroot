#!/bin/sh

[ -f rootfs.img ] || {
echo "Copy debootstrapped directory into rootfs.img first (do that manually please):"
echo "dd if=/dev/zero of=rootfs.img bs=1 count=0 seek=800M"
echo "mkfs.ext4 -b 4096 -F rootfs.img"
echo "mkdir rootfs"
echo "sudo mount -o loop rootfs.img rootfs"
echo "sudo cp -a dist-gimp-lenny/. rootfs"
echo "sudo umount rootfs"
echo "sudo apt-get install qemu-kvm-extras"
exit
}

[ -f vmlinuz ] || wget http://ports.ubuntu.com/ubuntu-ports/dists/lucid/main/installer-armel/current/images/versatile/netboot/vmlinuz
echo "Now run inside qemu window:"
echo "/debootstrap/debootstrap --second-stage"
echo "then close qemu, mount rootfs.img again, copy all contents back to dist-gimp-lenny, and run"
echo "prepare-img.sh dist-gimp-lenny /data/data/com.cuntubuntu/files"
qemu-system-arm \
        -M versatilepb \
        -cpu cortex-a8 \
        -hda rootfs.img \
        -m 400 \
        -kernel vmlinuz \
        -append 'rootwait root=/dev/sda init=/bin/sh rw'

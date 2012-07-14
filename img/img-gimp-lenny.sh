#!/bin/sh
echo "This image should be able run on devices with kernel 2.6.29"
DIST=lenny
VARIANT=gimp
sudo rm -r -f dist-$VARIANT-$DIST rootfs-$VARIANT-$DIST.img rootfs-$VARIANT-$DIST
sudo qemu-debootstrap --arch=armel --verbose \
        --components=main,contrib \
        --include=fakeroot,fakechroot \
        $DIST dist-$VARIANT-$DIST http://archive.debian.org/debian

echo "Copying debootstrapped directory into rootfs.img"
dd if=/dev/zero of=rootfs-$VARIANT-$DIST.img bs=1 count=0 seek=1000M
mkfs.ext3 -b 4096 -F rootfs-$VARIANT-$DIST.img
mkdir rootfs-$VARIANT-$DIST
sudo mount -o loop rootfs-$VARIANT-$DIST.img rootfs-$VARIANT-$DIST
sudo cp -a dist-$VARIANT-$DIST/. rootfs-$VARIANT-$DIST/
sudo cp qemu-install.sh rootfs-$VARIANT-$DIST/
sudo umount rootfs-$VARIANT-$DIST
sudo chmod a+w rootfs-$VARIANT-$DIST rootfs-$VARIANT-$DIST.img dist-$VARIANT-$DIST

[ -f vmlinuz ] || wget http://ports.ubuntu.com/ubuntu-ports/dists/lucid/main/installer-armel/current/images/versatile/netboot/vmlinuz

echo "Now run inside qemu window:"
echo "./qemu-install.sh"
echo "You may install additional packages using apt-get"
echo "Close qemu, mount rootfs.img again, copy all contents back to dist-gimp-lenny, and run"
echo "sudo ./prepare-img.sh dist-$VARIANT-$DIST /data/data/com.cuntubuntu/files"
qemu-system-arm -M versatilepb -cpu cortex-a8 -hda rootfs-$VARIANT-$DIST.img -m 256 -kernel vmlinuz -append 'rootwait root=/dev/sda init=/bin/sh rw'

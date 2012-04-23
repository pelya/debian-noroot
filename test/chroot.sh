#!/system/bin/sh

# FAKECHROOT_DEBUG=true \

env LD_LIBRARY_PATH=`pwd`/usr/local/lib:`pwd`/usr/lib/arm-linux-gnueabi:`pwd`/usr/lib:`pwd`/lib/arm-linux-gnueabi:`pwd`/lib:/system/lib:/usr/local/lib:/usr/lib/arm-linux-gnueabi:/usr/lib:/lib/arm-linux-gnueabi:/lib \
PATH=`pwd`/usr/local/sbin:`pwd`/usr/local/bin:`pwd`/usr/sbin:`pwd`/usr/bin:`pwd`/sbin:`pwd`/bin:`pwd`/usr/games:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games \
LD_PRELOAD=`pwd`/libfakechroot.so \
FAKECHROOT_EXCLUDE_PATH=/sdcard \
FAKECHROOT_ELFLOADER=`pwd`/lib/ld-linux.so.3 \
lib/ld-linux.so.3 \
usr/sbin/chroot `pwd` bin/bash

#!/system/bin/sh

case x$SDCARD in x ) export SDCARD=$EXTERNAL_STORAGE;; esac

SDCARD=`./busybox realpath $SDCARD`

export HOME=/home/$USER
export SHELL=/bin/bash
#export USER=root
#export LD_LIBRARY_PATH=/lib:/usr/local/lib:/usr/lib
export LD_LIBRARY_PATH=
export PATH=/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/games:/usr/games
export "LD_PRELOAD=/libdisableselinux.so /libandroid-shmem.so"
./proot -r `pwd` -w / -b /dev -b /proc -b /sys -b /system -b $SDCARD bin/bash -l

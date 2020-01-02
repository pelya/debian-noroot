#!/system/bin/sh

case x$SDCARD in x ) SDCARD=/sdcard;; esac

case x$SECURE_STORAGE_DIR in x ) export SECURE_STORAGE_DIR=/data/data/com.cuntubuntu/files ;; esac
cd $SECURE_STORAGE_DIR/img

case x$SDCARD in x ) export SDCARD=$EXTERNAL_STORAGE;; esac

SDCARD=`../busybox realpath $SDCARD`
STORAGE="-b $SDCARD"

export HOME=/home/$USER
export SHELL=/bin/bash
export LD_LIBRARY_PATH=$SECURE_STORAGE_DIR/usr/bin
export LD_PRELOAD=$SECURE_STORAGE_DIR/usr/bin/libandroid-shmem-disableselinux.so
export TZ="`getprop persist.sys.timezone`"
export PROOT_TMPDIR=`pwd`/tmp
export PROOT_TMP_DIR=$PROOT_TMPDIR
export PROOT_LOADER=$SECURE_STORAGE_DIR/usr/bin/loader
export PROOT_LOADER_32=$SECURE_STORAGE_DIR/usr/bin/loader32

ls -l $LD_PRELOAD
echo "Launching proot with arguments:" "$@"

../usr/bin/proot -r `pwd` -w / -b /dev -b /proc -b /sys -b /system -b /data -b /mnt -b /storage -b /odm -b /oem -b /vendor $STORAGE "$@"

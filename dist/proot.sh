#!/system/bin/sh

case x$SDCARD in x ) SDCARD=/sdcard;; esac

case x$SECURE_STORAGE_DIR in x ) export SECURE_STORAGE_DIR=/data/data/com.cuntubuntu/files ;; esac
cd $SECURE_STORAGE_DIR/img

case x$SDCARD in x ) SDCARD=$EXTERNAL_STORAGE;; esac

SDCARD=`../busybox realpath $SDCARD`

case x$OS_VERSION in x ) OS_VERSION="4.0.0";; esac
echo "Linux version $OS_VERSION (proot@proot) (gcc version 4.9.x) #1 SMP (2019-11-11)" > $SECURE_STORAGE_DIR/proc-version

export HOME=/home/$USER
export SHELL=/bin/bash
export LD_LIBRARY_PATH=$SECURE_STORAGE_DIR/usr/bin
export TZ="`getprop persist.sys.timezone`"
export PROOT_TMP_DIR=`pwd`/tmp
export PROOT_LOADER=$SECURE_STORAGE_DIR/usr/bin/loader
export PROOT_LOADER_32=$SECURE_STORAGE_DIR/usr/bin/loader32
#export PROOT_NO_SECCOMP=1

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games

../usr/bin/proot --link2symlink -r `pwd` -w / \
-b /dev -b /proc -b /sys -b /system -b /data -b /mnt -b /storage -b /odm -b /oem -b /vendor -b $SDCARD -b $SECURE_STORAGE_DIR/proc-version:/proc/version \
/usr/bin/env LD_PRELOAD=/libandroid-shmem-disableselinux.so LD_LIBRARY_PATH= \
"$@"

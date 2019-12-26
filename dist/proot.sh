#!/system/bin/sh

case x$SDCARD in x ) SDCARD=/sdcard;; esac

case x$SECURE_STORAGE_DIR in x ) echo > /dev/null;; * ) cd $SECURE_STORAGE_DIR/img;; esac

case x$SDCARD in x ) export SDCARD=$EXTERNAL_STORAGE;; esac

SDCARD=`../busybox realpath $SDCARD`
STORAGE="-b $SDCARD"

export HOME=/home/$USER
export SHELL=/bin/bash
export LD_LIBRARY_PATH=
# Java doesn't work in PRoot when started from /usr/bin/java symlink, so we have to put a path to java binary into PATH, and Java 6 fails on Samsung devices
#JAVA_PATH=/usr/lib/jvm/default-java/jre/bin:/usr/lib/jvm/default-java/bin
#ls usr/lib/jvm/java-7-openjdk-*/bin > /dev/null 2>&1 && JAVA_PATH=/`echo usr/lib/jvm/java-7-openjdk-*/jre/bin`:/`echo usr/lib/jvm/java-7-openjdk-*/bin`
export PATH=/usr/local/sbin:/usr/local/bin:$JAVA_PATH:/usr/sbin:/usr/bin:/sbin:/bin
export "LD_PRELOAD=/libdisableselinux.so /libandroid-shmem.so"
export PROOT_TMPDIR=`pwd`/tmp
export PROOT_TMP_DIR=$PROOT_TMPDIR
export TZ="`getprop persist.sys.timezone`"
../usr/bin/proot -r `pwd` -w / -b /dev -b /proc -b /sys -b /system -b /data -b /mnt -b /storage /b odm /b oem /b vendor $STORAGE "$@"

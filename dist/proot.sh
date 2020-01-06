#!/system/bin/sh

case x$SDCARD in x ) SDCARD=/sdcard;; esac

case x$SECURE_STORAGE_DIR in x ) export SECURE_STORAGE_DIR=/data/data/com.cuntubuntu/files ;; esac
cd $SECURE_STORAGE_DIR/img

case x$SDCARD in x ) export SDCARD=$EXTERNAL_STORAGE;; esac

SDCARD=`../busybox realpath $SDCARD`

export HOME=/home/$USER
export SHELL=/bin/bash
export LD_LIBRARY_PATH=$SECURE_STORAGE_DIR/usr/bin
export TZ="`getprop persist.sys.timezone`"
export PROOT_TMPDIR=`pwd`/tmp
export PROOT_TMP_DIR=$PROOT_TMPDIR
export PROOT_LOADER=$SECURE_STORAGE_DIR/usr/bin/loader
export PROOT_LOADER_32=$SECURE_STORAGE_DIR/usr/bin/loader32
#export PROOT_NO_SECCOMP=1

# Java doesn't work in PRoot when started from /usr/bin/java symlink, so we have to put a path to java binary into PATH, and Java 6 fails on Samsung devices
#JAVA_PATH=/usr/lib/jvm/default-java/jre/bin:/usr/lib/jvm/default-java/bin
#ls usr/lib/jvm/java-7-openjdk-*/bin > /dev/null 2>&1 && JAVA_PATH=/`echo usr/lib/jvm/java-7-openjdk-*/jre/bin`:/`echo usr/lib/jvm/java-7-openjdk-*/bin`
#export PATH=/usr/local/sbin:/usr/local/bin:$JAVA_PATH:/usr/sbin:/usr/bin:/sbin:/bin
#export PATH=$SECURE_STORAGE_DIR/img/usr/local/sbin:$SECURE_STORAGE_DIR/img/usr/local/bin:$SECURE_STORAGE_DIR/img/usr/sbin:$SECURE_STORAGE_DIR/img/usr/bin:$SECURE_STORAGE_DIR/img/usr/local/games:$SECURE_STORAGE_DIR/img/usr/games
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
#export LD_PRELOAD=
#export LD_PRELOAD=$SECURE_STORAGE_DIR/usr/bin/libandroid-shmem-disableselinux.so


../usr/bin/proot --link2symlink -r `pwd` -w / \
-b /dev -b /proc -b /sys -b /system -b /data -b /mnt -b /storage -b /odm -b /oem -b /vendor -b $SDCARD \
/usr/bin/env LD_PRELOAD=/libandroid-shmem-disableselinux.so LD_LIBRARY_PATH= \
"$@"

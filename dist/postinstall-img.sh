#!/system/bin/sh

case x$SDCARD in x ) export SDCARD=$EXTERNAL_STORAGE;; esac
echo "SDCARD path: $SDCARD"
case x$SECURE_STORAGE_DIR in x ) echo "Error: no SECURE_STORAGE_DIR envvar defined";; * ) cd $SECURE_STORAGE_DIR/img;; esac
echo "Changing curdir to: $SECURE_STORAGE_DIR/img"

umask 002

SDCARD=`../busybox realpath $SDCARD`
UNSECURE_STORAGE_DIR=`../busybox realpath $UNSECURE_STORAGE_DIR`

ln -s $SDCARD sdcard
mkdir -p .$SDCARD
mkdir -p .$UNSECURE_STORAGE_DIR

echo "Creating necessary directories"
# Random post-install cmds
mkdir var/run/dbus
mkdir var/run/xauth
mkdir run/dbus
mkdir run/xauth
ln -s /usr/bin/dbus-launch bin/dbus-launch
mkdir var/lib/dbus
mkdir root
mkdir root/Desktop
touch etc/mtab
ln -s $SDCARD root/sdcard
ln -s $SDCARD root/Desktop/sdcard

# Export GIMP config to SD card
case x$UNSECURE_STORAGE_DIR in x ) echo ... > /dev/null;; * ) ../busybox cp -r root/.gimp-2.8/. $UNSECURE_STORAGE_DIR/gimp/ ; ../busybox rm -rf root/.gimp-2.8 ; ln -s $UNSECURE_STORAGE_DIR/gimp root/.gimp-2.8 ; ln -s $UNSECURE_STORAGE_DIR/gimp/fonts root/.fonts ;; esac

echo "Adding user $USER ID $USER_ID"
# This command fails on Galaxy Note 3
#./chroot.sh bin/bash usr/bin/fakeroot-sysv usr/sbin/useradd -U -m -G sudo,staff  '$1$nFL/I4tz$zHKmBfkaKmRRmWje1Mupm0' -u $USER_ID $USER 2>&1
echo "$USER:x:$USER_ID:" >> etc/group
echo "$USER:!::" >> etc/gshadow
echo "$USER:x:$USER_ID:$USER_ID::/home/$USER:/bin/bash" >> etc/passwd
echo "$USER"':$1$nFL/I4tz$zHKmBfkaKmRRmWje1Mupm0:16019:0:99999:7:::' >> etc/shadow
mkdir home/$USER
../busybox cp -a -f etc/skel/. home/$USER/ 2>&1
../busybox cp -a -f root/. home/$USER/ 2>&1

echo "Updating locales for lang $LANG"
logwrapper ./proot.sh /postinstall-locales.sh

echo "Postinstall script finished"

echo "=== ./proot.sh /bin/ls -l /usr/sbin"
./proot.sh /bin/ls -l /usr/sbin
echo "=== ./proot.sh /bin/ls -l /data/data/com.cuntubuntu/files/img"
./proot.sh /bin/ls -l /data/data/com.cuntubuntu/files/img
echo "=== ls -l"
ls -l
echo "=== ./proot.sh /bin/ls -l"
./proot.sh /bin/ls -l
echo "=== ./proot.sh /system/bin/ls -l"
./proot.sh /system/bin/ls -l
echo "=== ./proot.sh /system/bin/ls --version"
./proot.sh /system/bin/ls --version
echo "=== ./proot.sh /bin/ls --version"
./proot.sh /bin/ls --version
echo "=== ./proot.sh /bin/sh -c echo ====shell===="
./proot.sh /bin/sh -c 'echo ====shell===='
echo "=== ./proot.sh /bin/sh -c set"
./proot.sh /bin/sh -c set
echo "=== ./proot.sh /bin/sh -c '/bin/ls -l'"
./proot.sh /bin/sh -c '/bin/ls -l'
echo "=== ./proot.sh /bin/sh -c '/bin/ls -l /usr/sbin'"
./proot.sh /bin/sh -c '/bin/ls -l /usr/sbin'
echo "=== ./proot.sh /bin/sh -c '/bin/ls -l /data/data/com.cuntubuntu/files/img'"
./proot.sh /bin/sh -c '/bin/ls -l /data/data/com.cuntubuntu/files/img'
echo "=== ./proot.sh /bin/sh -c '/bin/ls -l /data/data/com.cuntubuntu/files/img/usr/sbin'"
./proot.sh /bin/sh -c '/bin/ls -l /data/data/com.cuntubuntu/files/img/usr/sbin'
echo "=== ./proot.sh /bin/sh -c '/bin/ls --version'"
./proot.sh /bin/sh -c '/bin/ls --version'
echo "=== ./proot.sh /bin/sh -c 'ls --version'"
./proot.sh /bin/sh -c 'ls --version'
echo "=== ./proot.sh /bin/zcat --help"
./proot.sh /bin/zcat --help

echo "=== ./proot.sh /bin/sh -c '/bin/zcat --help'"
./proot.sh /bin/sh -c '/bin/zcat --help'

echo "=== ./proot.sh /bin/which ls"
./proot.sh /bin/which ls

echo "=== ./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so"
./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so

echo "=== ./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/ls -l"
./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/ls -l

echo "=== ./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/ls --version"
./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/ls --version

echo "=== ./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/sh -c 'echo ====shell===='"
./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/sh -c 'echo ====shell===='

echo "=== ./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/sh -c '/bin/ls -l'"
./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/sh -c '/bin/ls -l'

echo "=== ./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/sh -c '/bin/ls --version'"
./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/sh -c '/bin/ls --version'

echo "=== ./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/sh -c 'ls --version'"
./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/sh -c 'ls --version'

echo "=== ./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/sh -c 'which ls'"
./proot.sh /usr/lib/x86_64-linux-gnu/ld-2.28.so /bin/sh -c 'which ls'

echo "=== ./proot.sh /bin/sh -c 'which ls'"
./proot.sh /bin/sh -c 'which ls'

echo "=== ./proot.sh /ls-dbg --version"
./proot.sh  /ls-dbg --version

echo "=== ./proot.sh /ls-dbg -l"
./proot.sh  /ls-dbg -l

echo "=== ./proot.sh /ls-dbg -l /usr/sbin"
./proot.sh  /ls-dbg -l /usr/sbin

echo "=== debug done"

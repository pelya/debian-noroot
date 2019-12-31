#!/bin/sh

# Java doesn't work in PRoot when started from /usr/bin/java symlink, so we have to put a path to java binary into PATH, and Java 6 fails on Samsung devices
#JAVA_PATH=/usr/lib/jvm/default-java/jre/bin:/usr/lib/jvm/default-java/bin
#ls usr/lib/jvm/java-7-openjdk-*/bin > /dev/null 2>&1 && JAVA_PATH=/`echo usr/lib/jvm/java-7-openjdk-*/jre/bin`:/`echo usr/lib/jvm/java-7-openjdk-*/bin`
#export PATH=/usr/local/sbin:/usr/local/bin:$JAVA_PATH:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export "LD_PRELOAD=/libdisableselinux.so /libandroid-shmem.so"

rm -f /var/run/dbus/pid
fakeroot-tcp /usr/bin/env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dbus-daemon --system

sleep 1
dbus-launch --exit-with-session sh -c 'xfce4-session ; setsid sh -c "cd /proc/ ; for f in [0-9]* ; do [ \$f = \$\$ ] || kill -9 \$f ; done"' &

wait

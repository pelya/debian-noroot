#!/system/bin/sh

#export FAKECHROOT_DEBUG=true
export LD_LIBRARY_PATH=`pwd`/usr/local/lib:`pwd`/usr/lib/arm-linux-gnueabi:`pwd`/usr/lib:`pwd`/lib/arm-linux-gnueabi:`pwd`/lib:/system/lib:/usr/local/lib:/usr/lib/arm-linux-gnueabi:/usr/lib:/lib/arm-linux-gnueabi:/lib:`pwd`/usr/lib/arm-linux-gnueabi/libfakeroot
export "LD_PRELOAD=`pwd`/libfakechroot.so `pwd`/libfakedns.so"
export FAKECHROOT_EXCLUDE_PATH=/dev:/proc:/sys:/sdcard
export FAKECHROOT_ELFLOADER=`pwd`/lib/ld-linux.so.3
export PATH=`pwd`/usr/local/sbin:`pwd`/usr/local/bin:`pwd`/usr/sbin:`pwd`/usr/bin:`pwd`/sbin:`pwd`/bin:`pwd`/usr/games:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
lib/ld-linux.so.3 usr/sbin/chroot `pwd` fakeroot env HOME=/root USER=root TMPDIR=/tmp SHELL=/bin/bash bin/bash
# Xtightvnc :1111 -geometry 1280x800 -depth 16 -rfbwait 120000 -rfbport 7011 -rfbauth /root/.vnc/passwd -nevershared
# vncserver :1111 -geometry 1280x800 -depth 16 -nevershared
#echo Now connect with vncviewer to 127.0.0.1 port 7011 password ubuntu
# fakeroot vncserver :1111 -geometry $DISPLAY_RESOLUTION -depth 16 -nevershared

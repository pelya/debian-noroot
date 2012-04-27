#!/system/bin/sh

#export FAKECHROOT_DEBUG=true
# /usr/local/lib:/usr/lib/arm-linux-gnueabi:/usr/lib:/lib/arm-linux-gnueabi:/lib:
#export LD_LIBRARY_PATH=`pwd`/usr/local/lib:`pwd`/usr/lib/arm-linux-gnueabi:`pwd`/usr/lib:`pwd`/lib/arm-linux-gnueabi:`pwd`/lib:/system/lib:`pwd`/usr/lib/arm-linux-gnueabi/libfakeroot
# Overkill haha, gnome-session won't start otherwise
export LD_LIBRARY_PATH=`pwd`/lib:`pwd`/lib/arm-linux-gnueabi:`pwd`/lib/arm-linux-gnueabi/security:`pwd`/lib/security:`pwd`/usr/lib:`pwd`/usr/lib/arm-linux-gnueabi:`pwd`/usr/lib/arm-linux-gnueabi/dri:`pwd`/usr/lib/arm-linux-gnueabi/fakechroot:`pwd`/usr/lib/arm-linux-gnueabi/gconf/2:`pwd`/usr/lib/arm-linux-gnueabi/gconv:`pwd`/usr/lib/arm-linux-gnueabi/gdk-pixbuf-2.0/2.10.0/loaders:`pwd`/usr/lib/arm-linux-gnueabi/gio/modules:`pwd`/usr/lib/arm-linux-gnueabi/gtk-2.0/2.10.0/immodules:`pwd`/usr/lib/arm-linux-gnueabi/gtk-2.0/2.10.0/printbackends:`pwd`/usr/lib/arm-linux-gnueabi/gtk-3.0/3.0.0/immodules:`pwd`/usr/lib/arm-linux-gnueabi/gtk-3.0/3.0.0/printbackends:`pwd`/usr/lib/arm-linux-gnueabi/libfakeroot:`pwd`/usr/lib/arm-linux-gnueabi/openssl-1.0.0/engines:`pwd`/usr/lib/arm-linux-gnueabi/pango/1.6.0/modules:`pwd`/usr/lib/arm-linux-gnueabi/pkcs11:`pwd`/usr/lib/arm-linux-gnueabi/polkit-1/extensions:`pwd`/usr/lib/arm-linux-gnueabi/sasl2:`pwd`/usr/lib/coreutils:`pwd`/usr/lib/gcc/arm-linux-gnueabi/4.6:`pwd`/usr/lib/gnome-keyring/devel:`pwd`/usr/lib/imlib2/filters:`pwd`/usr/lib/imlib2/loaders:`pwd`/usr/lib/python2.7/dist-packages:`pwd`/usr/lib/python2.7/dist-packages/gi:`pwd`/usr/lib/python2.7/dist-packages/gi/_glib:`pwd`/usr/lib/python2.7/dist-packages/gi/_gobject:`pwd`/usr/lib/python2.7/lib-dynload:`pwd`/usr/lib/tc
export "LD_PRELOAD=`pwd`/libfakechroot.so `pwd`/libfakedns.so"
export FAKECHROOT_EXCLUDE_PATH=/dev:/proc:/sys:/sdcard
export FAKECHROOT_ELFLOADER=`pwd`/lib/ld-linux.so.3
export PATH=`pwd`/usr/local/sbin:`pwd`/usr/local/bin:`pwd`/usr/sbin:`pwd`/usr/bin:`pwd`/sbin:`pwd`/bin:`pwd`/usr/games:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
export DISPLAY=:1111
export HOME=/root
export USER=root
export TMPDIR=/tmp
export SHELL=/bin/bash
export TERM=linux
lib/ld-linux.so.3 usr/sbin/chroot `pwd` fakeroot usr/bin/gnome-session
# Xtightvnc :1111 -geometry 1280x800 -depth 16 -rfbwait 120000 -rfbport 7011 -rfbauth /root/.vnc/passwd -nevershared
# vncserver :1111 -geometry 1280x800 -depth 16 -nevershared
#echo Now connect with vncviewer to 127.0.0.1 port 7011 password ubuntu
# fakeroot vncserver :1111 -geometry $DISPLAY_RESOLUTION -depth 16 -nevershared

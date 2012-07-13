#!/bin/sh

case x$DISPLAY_RESOLUTION in x ) export DISPLAY_RESOLUTION=800x480;; esac

rm -f /var/run/dbus/pid
Xtightvnc :1111 -geometry $DISPLAY_RESOLUTION -depth 16 -rfbwait 120000 -rfbport 7011 -rfbauth /root/.vnc/passwd -nevershared &
sleep 5
dbus-daemon --system &
sleep 2
gimp &
abiword &
gnumeric &
if [ -f /usr/bin/xfce4-session ]; then xfce4-session; else synaptic; fi

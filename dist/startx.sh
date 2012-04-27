#!/bin/sh

case x$DISPLAY_RESOLUTION in x ) export DISPLAY_RESOLUTION=1280x800;; esac

Xtightvnc :1111 -geometry $DISPLAY_RESOLUTION -depth 16 -rfbwait 120000 -rfbport 7011 -rfbauth /root/.vnc/passwd -nevershared &
sleep 5
dbus-daemon --system &
#xfce4-session # Fails miserably, we'll start desktop & panel & window manager separately
sleep 5
xfdesktop &
sleep 5
xfce4-panel &
sleep 5
xfwm4

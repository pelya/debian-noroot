#!/bin/sh

case x$DISPLAY_RESOLUTION in x ) export DISPLAY_RESOLUTION=800x480;; esac

Xtightvnc :1111 -geometry $DISPLAY_RESOLUTION -depth 16 -rfbwait 120000 -rfbport 7011 -rfbauth /root/.vnc/passwd -nevershared &
sleep 5
dbus-daemon --system &
#xfce4-session # Works okay, but popups a dialog box
sleep 5
xfwm4 &
xfce4-panel &
#xfdesktop & # This worked in Precise, but fails in Natty
libreoffice


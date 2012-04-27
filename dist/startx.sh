#!/bin/sh

Xtightvnc :1111 -geometry $DISPLAY_RESOLUTION -depth 16 -rfbwait 120000 -rfbport 7011 -rfbauth /root/.vnc/passwd -nevershared &
sleep 3
xfce4-session &
sleep 7
xfdesktop &
sleep 5
xfce4-panel

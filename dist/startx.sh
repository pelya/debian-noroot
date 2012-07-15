#!/bin/sh

case x$DISPLAY_RESOLUTION in x ) export DISPLAY_RESOLUTION=800x480;; esac

rm -f /var/run/dbus/pid
if env DISPLAY=127.0.0.1:0 /usr/bin/xrefresh ; then
	export DISPLAY=127.0.0.1:0
else
	Xtightvnc :1111 -geometry $DISPLAY_RESOLUTION -depth 16 -rfbwait 120000 -rfbport 7011 -rfbauth /root/.vnc/passwd -nevershared &
fi
sleep 3
dbus-daemon --system &
sleep 2
/xterm.sh &
sleep 2
{ xfce4-session || { xfwm4 &
xfdesktop &
xfce4-panel &
}
} &
sleep 5
gimp &
abiword &
gnumeric &
synaptic &
wait

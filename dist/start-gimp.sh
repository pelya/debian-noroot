#!/bin/sh

rm -f /var/run/dbus/pid
dbus-daemon --system &
sleep 1
{
	xfce4-session || {
		xfwm4 || metacity &
		xfdesktop &
		xfce4-panel &
	}
} &
gimp &
inkscape &
wait

#!/bin/sh

export LANG=C
export LANGUAGE=C

rm -f /var/run/dbus/pid
dbus-daemon --system &
sleep 1
{
	dbus-launch --exit-with-session xfce4-session || {
		xfwm4 || metacity &
		xfdesktop &
		xfce4-panel &
	}
} &
gimp &
inkscape &
wait

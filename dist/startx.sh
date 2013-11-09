#!/bin/sh

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
wait

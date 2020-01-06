#!/bin/sh


/usr/bin/rm -f /var/run/dbus/pid
/usr/bin/fakeroot-tcp /usr/bin/env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/bin/dbus-daemon --system


/usr/bin/sleep 1
/usr/bin/dbus-launch --exit-with-session /usr/bin/xfce4-session


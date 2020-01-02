#!/bin/sh

rm -f /var/run/dbus/pid
fakeroot-tcp /usr/bin/env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dbus-daemon --system

sleep 1
dbus-launch --exit-with-session sh -c 'xfce4-session ; setsid sh -c "cd /proc/ ; for f in [0-9]* ; do [ \$f = \$\$ ] || kill -9 \$f ; done"' &

wait

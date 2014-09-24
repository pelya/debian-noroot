#!/bin/sh

rm -f /var/run/dbus/pid
dbus-daemon --system &
sleep 1
pulseaudio --start
pulseaudio --load="module-simple-protocol-unix rate=44100 format=s16le channels=2 playback=true socket=/img/tmp/audio-out"
dbus-launch --exit-with-session sh -c 'xfce4-session ; setsid sh -c "cd /proc/ ; for f in [0-9]* ; do [ \$f = \$\$ ] || kill -9 \$f ; done"' &

wait

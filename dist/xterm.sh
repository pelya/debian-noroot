#!/bin/sh

PORT=`date '+%N'`
PORT=`expr $PORT % 1000 + 32000`
echo Port $PORT

/bin/busybox telnetd -K -b 127.0.0.1:$PORT -l /bin/sh
sleep 3
/usr/bin/putty telnet://127.0.0.1:$PORT

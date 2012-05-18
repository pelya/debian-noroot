#!/bin/bash

PORT=$RANDOM
PORT=`expr $PORT + 32000`
echo Port $PORT

/bin/busybox telnetd -K -p $PORT -l /bin/bash
sleep 4
/usr/bin/putty telnet://127.0.0.1:$PORT

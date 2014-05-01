#!/bin/sh

[ -n "$1" ] && rsync -e ssh --progress -h --timeout 10 -a -v $* "pelya@frs.sourceforge.net:/home/frs/project/l/li/libsdl-android/ubuntu/14.05.01/"

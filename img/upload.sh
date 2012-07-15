#!/bin/sh
rsync -e ssh --progress -h --timeout 10 -a -v *.zip "pelya@frs.sourceforge.net:/home/frs/project/l/li/libsdl-android/ubuntu/"

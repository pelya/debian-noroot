#!/bin/sh

if /usr/bin/dpkg -s locales ; then
	echo "Updating locales for lang $LANG"
else
	echo "No locales package installed, nothing to do"
	exit
fi

echo "$LANG.UTF-8 UTF-8" >> /etc/locale.gen
/usr/bin/fakeroot-tcp /usr/sbin/dpkg-reconfigure --frontend=noninteractive locales


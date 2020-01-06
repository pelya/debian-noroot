#!/bin/sh

echo "$0 - updating locales"

echo "$0 - updating locales 2"

#export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "$0 - updating locales 3"

if /usr/bin/dpkg -s locales ; then
	echo "Updating locales for lang $LANG"
else
	echo "No locales package installed, nothing to do"
	exit
fi

echo "$0 - updating locales 4"

echo "$LANG UTF-8" >> /etc/locale.gen
/usr/bin/fakeroot-tcp /usr/sbin/dpkg-reconfigure --frontend=noninteractive locales

echo "$0 - updating locales done"

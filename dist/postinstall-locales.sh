#!/bin/sh

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if /usr/bin/dpkg -s locales >/dev/null 2>&1 ; then
	echo "Updating locales for lang $LANG" | tee -a /tmp/postinstall-locales.log
else
	echo "No locales package installed, nothing to do" | tee -a /tmp/postinstall-locales.log
	exit
fi

echo "$LANG UTF-8" >> /etc/locale.gen
/usr/bin/fakeroot /usr/sbin/dpkg-reconfigure --frontend=noninteractive locales | tee -a /tmp/postinstall-locales.log

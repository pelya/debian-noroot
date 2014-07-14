#!/system/bin/sh

DNS1=`getprop net.dns1`
DNS2=`getprop net.dns2`
DNS3=`getprop net.dns3`
case x$DNS1 in x ) DNS1=8.8.8.8;; esac
case x$DNS2 in x ) DNS2=8.8.8.8;; esac
case x$DNS3 in x ) DNS3=8.8.8.8;; esac

echo nameserver $DNS1 > etc/resolv.conf
echo nameserver $DNS2 >> etc/resolv.conf
echo nameserver $DNS3 >> etc/resolv.conf

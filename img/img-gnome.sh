#!/bin/sh
sudo rootstock \
        --fqdn twit \
        --login ubuntu \
        --password ubuntu \
        --imagesize 2G \
        --seed ubuntu-minimal,gnome-session-bin,rxvt,eterm,fakeroot,fakechroot,tightvncserver,synaptic,wget,dnsutils,bind9-host \
        --dist precise \
        --components main,universe,restricted,multiverse \
        
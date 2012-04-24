#!/bin/sh
sudo rootstock \
        --fqdn twit \
        --login ubuntu \
        --password ubuntu \
        --imagesize 2G \
        --seed ubuntu-minimal,xfce4,fakeroot,fakechroot,tightvncserver,synaptic \
        --dist precise \
        --components main,universe,restricted,multiverse \
        
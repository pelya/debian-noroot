#!/bin/sh
sudo rootstock \
        --fqdn twit \
        --login ubuntu \
        --password ubuntu \
        --imagesize 2G \
        --seed ubuntu-minimal,lxde,fakeroot,fakechroot,tightvncserver,synaptic,wget \
        --dist precise \
        --components main,universe,restricted,multiverse \
        
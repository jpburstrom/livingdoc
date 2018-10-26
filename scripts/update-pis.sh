#!/bin/bash

OTHERROOT=/home/pi/livingdoc


# ssh to all pis and git pull
ro='sudo mount -o remount,ro / ; sudo mount -o remount,ro /boot'
rw='sudo mount -o remount,rw / ; sudo mount -o remount,rw /boot'

cd `git rev-parse --show-toplevel`

for pi in `arp -a | grep b8:27:eb | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`; do
    ssh pi@$pi /bin/bash << EOF
    hostname &&
    $rw &&
    cd $OTHERROOT &&
    git pull
EOF
    for dir in setup/*/samples; do
        rsync -a $dir/ pi@$pi:$OTHERROOT/$dir
    done

ssh pi@$pi /bin/bash << EOF
    sudo systemctl restart autoplay &&
    $ro
EOF
done



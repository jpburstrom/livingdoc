#!/bin/bash

# ssh to all pis and git pull
ro='sudo mount -o remount,ro / ; sudo mount -o remount,ro /boot'
rw='sudo mount -o remount,rw / ; sudo mount -o remount,rw /boot'

for pi in `arp -a | grep b8:27:eb | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`; do
    ssh pi@$pi /bin/bash << EOF
    $rw &&
    cd /home/pi/livingdoc &&
    git pull &&
    sudo systemctl restart autoplay
EOF
done



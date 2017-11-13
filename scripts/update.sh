#!/bin/bash

function ro {
    sudo mount -o remount,ro /
}
function rw {
    sudo mount -o remount,rw /
}

cd `dirname $0`
if [ -f /boot/updateme ]; then
    rw && ./pull.sh && ./install.sh
    ro
fi

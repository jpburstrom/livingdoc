#!/bin/bash

function ro {
    sudo mount -o remount,ro /
}
function rw {
    sudo mount -o remount,rw /
}

cd `dirname $0`
if [ -f /boot/updateme ]; then
    rw && ./pull.sh && ./install.sh && sudo systemctl restart autoplay && sudo systemctl restart custom-shell && sudo systemctl restart node-server
    ro
fi

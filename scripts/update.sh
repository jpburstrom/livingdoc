#!/bin/bash

alias ro='sudo mount -o remount,ro /'
alias rw='sudo mount -o remount,rw /'
cd `dirname $0`
if [ -f /tmp/updateme ]; then
    rw && ./pull.sh && ./install.sh
    ro
fi

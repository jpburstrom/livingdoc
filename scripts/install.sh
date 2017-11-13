#!/bin/bash

function ask_input() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

cd `dirname $0`

#sudo cp 11-automount-usb.rules /etc/udev/rules.d/
sudo cp ../system/*.service /etc/systemd/system/
sudo systemctl enable node-server
sudo apt install python-liblo

#if [[ "yes" == $(ask_input "Install USB mounting rules?") ]] 
#then
#    sudo systemctl enable on-usb-mount
#fi

#if [[ "yes" == $(ask_input "Install autoplay?") ]] 
#then
#    sudo systemctl enable autoplay
#fi

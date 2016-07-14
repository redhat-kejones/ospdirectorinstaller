#!/usr/bin/bash
if [ $# -ne 1 ]
then
    echo "Usage: $(basename $0) DNS-Server-IP"
    exit 1
fi

source ~/stackrc
DNS=$1
neutron subnet-update $(neutron subnet-list | awk '/start/ {print $2}') --dns-nameserver $DNS

#!/usr/bin/bash

for i in $(ironic node-list | grep -v UUID | awk '{print $2;}' | sed -e /^$/d); do ironic node-show $i | grep -A1 properties; echo "========="; done;

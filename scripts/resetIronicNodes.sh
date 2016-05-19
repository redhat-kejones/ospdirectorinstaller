#!/usr/bin/bash

for i in $(ironic node-list | grep -v UUID | awk '{print $2;}' | sed -e /^$/d); do ironic node-set-power-state $i off; done;
for i in $(ironic node-list | grep -v UUID | awk '{print $2;}' | sed -e /^$/d); do ironic node-set-provision-state $i provide; done;

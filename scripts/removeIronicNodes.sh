#!/usr/bin/bash

for i in $(ironic node-list | grep -v UUID | awk '{print $2;}' | sed -e /^$/d); do ironic node-delete $i; done;

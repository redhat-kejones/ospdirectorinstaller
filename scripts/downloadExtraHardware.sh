#!/usr/bin/bash

for i in $(ironic node-list | grep -v UUID | awk '{print $2;}' | sed -e /^$/d); do OS_TENANT_NAME=service swift download ironic-discoverd extra_hardware-$i; cat extra_hardware-$i | python -m json.tool > node-$i; echo "Downloaded extra_hardware for node $i"; done;

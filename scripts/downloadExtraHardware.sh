#!/usr/bin/bash

mkdir swift-data
cd swift-data
export IRONIC_DISCOVERD_PASSWORD=`sudo grep admin_password /etc/ironic-inspector/inspector.conf | egrep -v '^#'  | awk '{print $NF}'`

for node in $(ironic node-list | grep -v UUID| awk '{print $2}'); do swift -U service:ironic -K $IRONIC_DISCOVERD_PASSWORD download ironic-inspector inspector_data-$node; cat inspector_data-$node | python -m json.tool > node-$node; echo "Downloaded extra_hardware for node $node"; done

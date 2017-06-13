#!/usr/bin/env bash

source /home/stack/stackrc

mkdir -p /home/stack/nodes

for node in $(ironic node-list | grep -v UUID| awk '{print $2}'); do 
  echo $node
  openstack baremetal introspection data save $node | python -mjson.tool > /home/stack/nodes/overcloud-$node;
done

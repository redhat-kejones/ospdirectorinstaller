#!/usr/bin/bash
source /home/stack/stackrc
openstack catalog show nova
openstack host list
curl -s http://$1:9696 | python -m json.tool

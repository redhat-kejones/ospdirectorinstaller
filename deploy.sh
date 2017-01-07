#!/usr/bin/env bash

source ~/stackrc

cd ~

time openstack overcloud deploy --templates \
-e /home/stack/templates/environments/storage-environment.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
-e /home/stack/templates/network-environment.yaml \
-e /home/stack/templates/firstboot-environment.yaml \
--control-flavor control \
--compute-flavor compute \
--ceph-storage-flavor ceph-storage \
--control-scale 1 \
--compute-scale 1 \
--ceph-storage-scale 0 \
--ntp-server time.nist.gov \
--neutron-tunnel-types vxlan \
--neutron-network-type vxlan \
#--neutron-bridge-mappings datacentre:br-ex,tenant:br-tenant,storage:br-storage \
#--neutron-network-vlan-ranges datacentre:1:1000,tenant:1:1000,storage:1:1000 \

#!/usr/bin/bash

sudo rm -rf /var/log/heat/heat-engine.log
sudo rm -rf /var/log/heat/heat-api.log

sudo rm -rf /var/log/nova/nova-api.log
sudo rm -rf /var/log/nova/nova-conductor.log
sudo rm -rf /var/log/nova/nova-compute.log
sudo rm -rf /var/log/nova/nova-scheduler.log

sudo rm -rf /var/log/ironic/ironic-api.log
sudo rm -rf /var/log/ironic/ironic-conductor.log

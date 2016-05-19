#!/usr/bin/bash

cp ~/.ssh/id_rsa /tmp/id_rsa

sed -i ':a;N;$!ba;s/\n/\\n/g' /tmp/id_rsa

jq . << EOF > ~/instackenv.json
{
  "ssh-user": "stack",
  "ssh-key": "$(cat /tmp/id_rsa)",
  "power_manager": "nova.virt.baremetal.virtual_power_driver.VirtualPowerManager",
  "host-ip": "172.31.16.4",
  "arch": "x86_64",
  "nodes": [
    {
      "name": "overcloud-ceph1",
      "pm_addr": "172.31.16.4",
      "pm_password": "$(cat /tmp/id_rsa)",
      "pm_type": "pxe_ssh",
      "mac": [
        "$(sed -n 1p /tmp/nodes.txt)"
      ],
      "cpu": "4",
      "memory": "8192",
      "disk": "60",
      "arch": "x86_64",
      "pm_user": "stack"
    },
    {
      "name": "overcloud-compute1",
      "pm_addr": "172.31.16.4",
      "pm_password": "$(cat /tmp/id_rsa)",
      "pm_type": "pxe_ssh",
      "mac": [
        "$(sed -n 2p /tmp/nodes.txt)"
      ],
      "cpu": "4",
      "memory": "8192",
      "disk": "60",
      "arch": "x86_64",
      "pm_user": "stack"
    },
    {
      "name": "overcloud-controller1",
      "pm_addr": "172.31.16.4",
      "pm_password": "$(cat /tmp/id_rsa)",
      "pm_type": "pxe_ssh",
      "mac": [
        "$(sed -n 3p /tmp/nodes.txt)"
      ],
      "cpu": "4",
      "memory": "8192",
      "disk": "60",
      "arch": "x86_64",
      "pm_user": "stack"
    }
  ]
}
EOF

rm /tmp/id_rsa

#!/usr/bin/bash

source /home/stack/stackrc

#Controllers
ironic node-update 39aae971-7094-42fb-b4a0-26f79a399570 add properties/capabilities='profile:control,boot_option:local'
ironic node-update 2b60cc35-bdc5-4556-aa64-7bd4c53d3bca add properties/capabilities='profile:control,boot_option:local'
ironic node-update b1bdc2d4-e1ee-4243-8141-d14bbad3f27b add properties/capabilities='profile:control,boot_option:local'

#Computes
ironic node-update a961c89a-fe6f-44d5-b82a-33a2f19a6da4 add properties/capabilities='profile:compute,boot_option:local'
ironic node-update a80e886c-2b8e-4e1f-b792-1678bb8835e3 add properties/capabilities='profile:compute,boot_option:local'
ironic node-update ba04b44e-42a5-43c6-9f3c-b7adb0723274 add properties/capabilities='profile:compute,boot_option:local'

#Cephs
ironic node-update a573cd67-cc47-4b8e-8d19-c687c5a8bf2a add properties/capabilities='profile:ceph-storage,boot_option:local'
ironic node-update 53a50574-011b-4da0-a3db-5b6ebd8cf959 add properties/capabilities='profile:ceph-storage,boot_option:local'
ironic node-update 5c102e1e-2b21-4748-8e0b-ecfeecd2039a add properties/capabilities='profile:ceph-storage,boot_option:local'


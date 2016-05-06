#!/usr/bin/bash  

source /home/stack/stackrc  

openstack flavor set --property "cpu_arch=x86_64" --property "capabilities:boot_option=local" --property "capabilities:profile=compute" compute  
openstack flavor set --property "cpu_arch=x86_64" --property "capabilities:boot_option=local" --property "capabilities:profile=control" control  
openstack flavor set --property "cpu_arch=x86_64" --property "capabilities:boot_option=local" --property "capabilities:profile=ceph" ceph 

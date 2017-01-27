#!/usr/bin/bash

#Parameters
user=operator
password=redhat
email=operator@redhat.com
tenant=operators
externalNetwork=public
externalCidr='10.16.0.0/24'
externalGateway='10.16.0.1'
externalDns='10.16.0.1'
externalFipStart='10.16.0.100'
externalFipEnd='10.16.0.250'
tenantNetwork=private
tenantCidr='192.168.1.0/24'
keypairName=operator
keypairPubkey="Enter Public Key Here"

#Start as the admin user
source ~/overcloudrc

#Create the operators tenant and operator user defined above
openstack project create $tenant --description "Project intended for shared resources and testing by Operators" --enable
openstack user create $user --project $tenant --password $password --email $email --enable

#Grant the admin role to the operator admin
openstack role add admin --user $user --project $tenant

#create an rc file for the new operator user
cp overcloudrc ${user}rc
sed -i "s/\(export OS_USERNAME=\).*/\1${user}/" ${user}rc
sed -i "s/\(export OS_TENANT_NAME=\).*/\1${tenant}/" ${user}rc
sed -i "s/\(export OS_PASSWORD=\).*/\1${password}/" ${user}rc

#Switch to the new operator
source ~/${user}rc

#Add ICMP and SSH incoming rules to the default security group in operators tenant
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

#Create a temp public key file
echo $keypairPubkey > /tmp/${keypairName}.pub
#Import the public key for the operator user
nova keypair-add --pub-key /tmp/${keypairName}.pub $keypairName

#Download the cirros test image
curl -o /tmp/cirros.qcow2 http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
#Upload the cirros test image to glance and share publicly
glance image-create --name cirros --disk-format qcow2 \
  --container-format bare --is-public true --file /tmp/cirros.qcow2

#Create a base flavor for use later
openstack flavor create --id 1 --ram 512 --disk 1 --vcpus 1 --public m1.tiny

#Create shared external network via flat provider type
neutron net-create $externalNetwork --provider:network_type flat --provider:physical_network datacentre --shared --router:external 
#Create external network via vxlan
#neutron net-create $externalNetwork --shared --router:external 

#Create external subnet
neutron subnet-create $externalNetwork $externalCidr --name ${externalNetwork}-sub --disable-dhcp --allocation-pool=start=$externalFipStart,end=$externalFipEnd --gateway=$externalGateway --dns-nameserver $externalDns

#Create a private tenant vxlan network
neutron net-create $tenantNetwork

#Create private tenant subnet
neutron subnet-create $tenantNetwork $tenantCidr --name ${tenantNetwork}-sub --dns-nameserver $externalDns

#Create a router
neutron router-create router-$tenantNetwork
#Add an interface on the router for the tenant network
neutron router-interface-add router-$tenantNetwork ${tenantNetwork}-sub
#Set the external gateway on the new router
neutron router-gateway-set router-$tenantNetwork $externalNetwork

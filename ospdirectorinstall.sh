#!/bin/bash
######## RHN CONFIG ######################################################
RHNUSER=YOURUSER
RHNPASSWORD=YOURPASSWORD
POOLID=YOURPOOLID
######## HOSTNAME CONFIG #################################################
MGMT_IP=10.16.0.5
FQDN=undercloud.example.com
SHORT=undercloud
######## Stack User Password #############################################
PASSWD=redhat
######## undercloud.conf #################################################
UNDERCLOUD_HOSTNAME=$FQDN
# IP information for the interface on the Undercloud that will be        
# handling the PXE boots and DHCP for Overcloud instances.  The IP       
# portion of the value will be assigned to the network interface         
# defined by local_interface, with the netmask defined by the prefix     
# portion of the value. (string value)                                   
LOCAL_IP=172.16.0.5/24
# Virtual IP address to use for the public endpoints of Undercloud      
# services. (string value)
UNDERCLOUD_PUBLIC_VIP=10.16.0.5
# Virtual IP address to use for the admin endpoints of Undercloud
# services. (string value)
UNDERCLOUD_ADMIN_VIP=172.16.0.6
# Generate certificate file to use for OpenStack service SSL connections.
# (string value)
GENERATE_SERVICE_CERTIFICATE=false
CERTIFICATE_GENERATION_CA=local
#UNDERCLOUD_SERVICE_CERTIFICATE=undercloud.pem --> This is not working yet
# Network interface on the Undercloud that will be handling the PXE
# boots and DHCP for Overcloud instances. (string value)
LOCAL_IFACE=eth0
# Network that will be masqueraded for external access, if required.
# This should be the subnet used for PXE booting. (string value)
MASQUERADE_NETWORK=172.16.0.0/24
# Start of DHCP allocation range for PXE and DHCP of Overcloud
# instances. (string value)
DHCP_START=172.16.0.80
# End of DHCP allocation range for PXE and DHCP of Overcloud
# instances. (string value)
DHCP_END=172.16.0.100
# Network CIDR for the Neutron-managed network for Overcloud
# instances. This should be the subnet used for PXE booting. (string
# value)
NETWORK_CIDR=172.16.0.0/24
# Network gateway for the Neutron-managed network for Overcloud
# instances. This should match the local_ip above when using
# masquerading. (string value)
NETWORK_GATEWAY=172.16.0.1
# Network interface on which discovery dnsmasq will listen.  If in
# doubt, use the default value. (string value)
INSPECTION_INTERFACE=br-ctlplane
# Temporary IP range that will be given to nodes during the discovery
# process.  Should not overlap with the range defined by dhcp_start
# and dhcp_end, but should be in the same network. (string value)
INSPECTION_IP_START=172.16.0.200
INSPECTION_IP_END=172.16.0.220
# Whether to run benchmarks when discovering nodes. (boolean value)
INSPECTION_RUNBENCH_BOOL=false
# Whether to enable the debug log level for Undercloud OpenStack
# services. (boolean value)
UNDERCLOUD_DEBUG_BOOL=false
# Defines whether to install the validation tools. The default is set
# to false, but you can can enable using true. 
ENABLE_TEMPEST=false
# Defines whether to install the OpenStack Workflow Service (mistral)
# in the undercloud.
ENABLE_MISTRAL=true
# Defines whether to install the OpenStack Messaging Service (zaqar)
# in the undercloud.
ENABLE_ZAQAR=true
# Defines whether to install OpenStack Telemetry (ceilometer, aodh)
# services in the undercloud.
ENABLE_TELEMETRY=true
# Defines Whether to install the director’s web UI. This allows
# you to perform overcloud planning and deployments through a
# graphical web interface. For more information, see Chapter 6,
# Configuring Basic Overcloud Requirements with the Web UI. Note
# that the UI is only available with SSL/TLS enabled using either
# the undercloud_service_certificate or generate_service_certificate.
ENABLE_UI=true
# Defines whether to install the requirements to run validations.
ENABLE_VALIDATIONS=true
# Defines whether to use iPXE or standard PXE. The default is true,
# which enables iPXE. Set to false to set to standard PXE.
IPXE_DEPLOY=true
# Defines whether to store events in Ceilometer on the Undercloud.
STORE_EVENTS=false
# Defines whether to wipe the hard drive of overcloud nodes between
# deployments and after the introspection.
CLEAN_NODES=false
# Set admin password for undercloud
UNDERCLOUD_ADMIN_PASSWORD=redhat
############################################################################


echo $"
   ___  ____  ____     _ _               _             
  / _ \/ ___||  _ \ __| (_)_ __ ___  ___| |_ ___  _ __ 
 | | | \___ \| |_) / _  | |  __/ _ \/ __| __/ _ \|  __|
 | |_| |___) |  __/ (_| | | | |  __/ (__| || (_) | |   
  \___/|____/|_|   \__ _|_|_|  \___|\___|\__\___/|_|   
  _           _        _ _                             
 (_)_ __  ___| |_ __ _| | | ___ _ __                   
 | |  _ \/ __| __/ _  | | |/ _ \  __|                  
 | | | | \__ \ || (_| | | |  __/ |                     
 |_|_| |_|___/\__\__ _|_|_|\___|_|                     
                                                       
 +-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+
 |b|y| |L|a|u|r|e|n|t| |D|o|m|b|
 +-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+
"

echo "Creating user stack"
useradd stack
echo $PASSWD | passwd stack --stdin
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

echo -e "$MGMT_IP\t\t$FQDN\t$SHORT" >> /etc/hosts

hostnamectl set-hostname $FQDN
hostnamectl set-hostname --transient $FQDN
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-ipforward.conf
sysctl -p /etc/sysctl.d/99-ipforward.conf

echo "Registering System"
subscription-manager register --username=$RHNUSER --password=$RHNPASSWORD
subscription-manager attach --pool=$POOLID
subscription-manager repos --disable='*'
subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-rh-common-rpms --enable=rhel-ha-for-rhel-7-server-rpms --enable=rhel-7-server-openstack-10-rpms --enable=rhel-7-server-openstack-10-devtools-rpms --enable=rhel-7-server-satellite-tools-6.2-rpms --enable=rhel-7-server-rhceph-2-osd-rpms --enable=rhel-7-server-rhceph-2-mon-rpms

echo "Updating system"
yum install vim screen tree wget yum-utils facter crudini git libguestfs-tools-c -y && yum update -y

mkdir -p /home/stack/{images,templates} 
chown -R stack.stack /home/stack

echo "Installing  python-tripleoclient"
sudo -H -u stack bash -c 'sudo yum install -y python-tripleoclient' 
sudo -H -u stack bash -c 'sudo cp /usr/share/instack-undercloud/undercloud.conf.sample ~/undercloud.conf' 
chown -R stack.stack /home/stack/undercloud.conf
cd /home/stack

echo "Installing overcloud images"
sudo yum install -y rhosp-director-images rhosp-director-images-ipa
sudo -H -u stack bash -c 'sudo cp /usr/share/rhosp-director-images/overcloud-full-latest-10.0.tar ~/images/'
sudo -H -u stack bash -c 'sudo cp /usr/share/rhosp-director-images/ironic-python-agent-latest-10.0.tar ~/images/'
cd /home/stack/images
for tarfile in *.tar; do tar -xf $tarfile; done
chown -R stack.stack /home/stack/images

echo "Disabling $LOCAL_IFACE for undercloud install"
sed -i s/ONBOOT=.*/ONBOOT=no/g /etc/sysconfig/network-scripts/ifcfg-$LOCAL_IFACE
 
#echo "Create Certs"
#mkdir -p /etc/pki/instack-certs
#openssl genrsa -out privkey.pem 2048
#sudo openssl req -new -x509 -key privkey.pem -out cacert.pem -days 365
#cat /home/stack/cacert.pem privkey.pem > /home/stack/undercloud.pem 
#chown stack.stack /home/stack/{undercloud.pem,cacert.pem,privkey.pem}
#cp /home/stack/undercloud.pem /etc/pki/instack-certs/
#semanage fcontext -a -t haproxy_exec_t "/etc/pki/instack-certs(/.*)?"
#restorecon -Rv /etc/pki/instack-certs 

echo "Modifying undercloud.conf"
crudini --set /home/stack/undercloud.conf DEFAULT undercloud_hostname $UNDERCLOUD_HOSTNAME
crudini --set /home/stack/undercloud.conf DEFAULT local_ip $LOCAL_IP
crudini --set /home/stack/undercloud.conf DEFAULT undercloud_public_vip  $UNDERCLOUD_PUBLIC_VIP
crudini --set /home/stack/undercloud.conf DEFAULT undercloud_admin_vip $UNDERCLOUD_ADMIN_VIP
crudini --set /home/stack/undercloud.conf DEFAULT generate_service_certificate $GENERATE_SERVICE_CERTIFICATE
crudini --set /home/stack/undercloud.conf DEFAULT certificate_generation_ca $CERTIFICATE_GENERATION_CA
crudini --set /home/stack/undercloud.conf DEFAULT local_interface $LOCAL_IFACE
crudini --set /home/stack/undercloud.conf DEFAULT masquerade_network $MASQUERADE_NETWORK
crudini --set /home/stack/undercloud.conf DEFAULT dhcp_start $DHCP_START
crudini --set /home/stack/undercloud.conf DEFAULT dhcp_end $DHCP_END
crudini --set /home/stack/undercloud.conf DEFAULT network_cidr $NETWORK_CIDR
crudini --set /home/stack/undercloud.conf DEFAULT network_gateway $NETWORK_GATEWAY
crudini --set /home/stack/undercloud.conf DEFAULT inspection_iprange $INSPECTION_IP_START,$INSPECTION_IP_END
crudini --set /home/stack/undercloud.conf DEFAULT inspection_runbench $INSPECTION_RUNBENCH_BOOL
crudini --set /home/stack/undercloud.conf DEFAULT undercloud_debug $UNDERCLOUD_DEBUG_BOOL
crudini --set /home/stack/undercloud.conf DEFAULT image_path /home/stack/images
crudini --set /home/stack/undercloud.conf DEFAULT inspection_interface $INSPECTION_INTERFACE
crudini --set /home/stack/undercloud.conf DEFAULT enable_tempest $ENABLE_TEMPEST
crudini --set /home/stack/undercloud.conf DEFAULT enable_mistral $ENABLE_MISTRAL
crudini --set /home/stack/undercloud.conf DEFAULT enable_zaqar $ENABLE_ZAQAR
crudini --set /home/stack/undercloud.conf DEFAULT enable_telemetry $ENABLE_TELEMETRY
crudini --set /home/stack/undercloud.conf DEFAULT enable_ui $ENABLE_UI
crudini --set /home/stack/undercloud.conf DEFAULT enable_validations $ENABLE_VALIDATIONS
crudini --set /home/stack/undercloud.conf DEFAULT ipxe_deploy $IPXE_DEPLOY
crudini --set /home/stack/undercloud.conf DEFAULT store_events $STORE_EVENTS
crudini --set /home/stack/undercloud.conf DEFAULT clean_nodes $CLEAN_NODES
crudini --set /home/stack/undercloud.conf auth undercloud_admin_password $UNDERCLOUD_ADMIN_PASSWORD

echo "Launch the following command as user STACK!"
echo "su - stack"
echo "screen"
echo "openstack undercloud install"
echo "CTRL a d"

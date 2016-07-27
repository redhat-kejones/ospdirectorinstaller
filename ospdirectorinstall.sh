#!/bin/bash
######## RHN CONFIG ######################################################
RHNUSER=YOURUSER
RHNPASSWORD=YOURPASSWORD
POOLID=YOURPOOLID
######## HOSTNAME CONFIG #################################################
MGMT_IP=172.16.0.5
FQDN=undercloud.example.com
SHORT=undercloud
######## Stack User Password #############################################
PASSWD=redhat
######## undercloud.conf #################################################
# IP information for the interface on the Undercloud that will be        
# handling the PXE boots and DHCP for Overcloud instances.  The IP       
# portion of the value will be assigned to the network interface         
# defined by local_interface, with the netmask defined by the prefix     
# portion of the value. (string value)                                   
LOCAL_IP=172.16.0.5/24
# Virtual IP address to use for the public endpoints of Undercloud      
# services. (string value)
UNDERCLOUD_PUBLIC_VIP=172.16.0.10
# Virtual IP address to use for the admin endpoints of Undercloud
# services. (string value)
UNDERCLOUD_ADMIN_VIP=172.16.0.11
# Certificate file to use for OpenStack service SSL connections.
# (string value)
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
DISCOVERY_INTERFACE=br-ctlplane
# Temporary IP range that will be given to nodes during the discovery
# process.  Should not overlap with the range defined by dhcp_start
# and dhcp_end, but should be in the same network. (string value)
DISCOVERY_IP_START=172.16.0.200
DISCOVERY_IP_END=172.16.0.220
# Whether to run benchmarks when discovering nodes. (boolean value)
DISCOVERY_RUNBENCH_BOOL=false
# Whether to enable the debug log level for Undercloud OpenStack
# services. (boolean value)
UNDERCLOUD_DEBUG_BOOL=false
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
subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-optional-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-rh-common-rpms --enable=rhel-7-server-satellite-tools-6.1-rpms --enable=rhel-ha-for-rhel-7-server-rpms --enable=rhel-7-server-openstack-8-rpms --enable=rhel-7-server-openstack-8-director-rpms --enable=rhel-7-server-rhceph-1.3-osd-rpms --enable=rhel-7-server-rhceph-1.3-mon-rpms

echo "Setting Repo Priorities"
yum-config-manager --enable rhel-7-server-openstack-8-rpms --setopt="rhel-7-server-openstack-8-rpms.priority=1" && yum-config-manager --enable rhel-7-server-rpms --setopt="rhel-7-server-rpms.priority=1" && yum-config-manager --enable rhel-7-server-optional-rpms --setopt="rhel-7-server-optional-rpms.priority=1" && yum-config-manager --enable rhel-7-server-extras-rpms --setopt="rhel-7-server-extras-rpms.priority=1" && yum-config-manager --enable rhel-7-server-openstack-8-director-rpms --setopt="rhel-7-server-openstack-8-director-rpms.priority=1" && yum-config-manager --enable rhel-7-server-rh-common-rpms --setopt="rhel-7-server-rh-common-rpms.priority=1" && yum-config-manager --enable rhel-7-server-satellite-tools-6.1-rpms --setopt="rhel-7-server-satellite-tools-6.1-rpms.priority=1" && yum-config-manager --enable rhel-ha-for-rhel-7-server-rpms --setopt="rhel-ha-for-rhel-7-server-rpms.priority=1" && yum-config-manager --enable rhel-7-server-rhceph-1.3-osd-rpms --setopt="rhel-7-server-rhceph-1.3-osd-rpms.priority=1" && yum-config-manager --enable rhel-7-server-rhceph-1.3-mon-rpms --setopt="rhel-7-server-rhceph-1.3-mon-rpms.priority=1"

echo "Updating system"
yum install vim screen tree wget yum-plugin-priorities yum-utils facter openstack-utils git libguestfs-tools-c -y && yum update -y

echo "Installing ansible"
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install epel-release-latest-7.noarch.rpm -y
yum install ansible -y

mkdir -p /home/stack/{images,templates} 
chown -R stack.stack /home/stack

echo "Installing  python-rdomanager-oscplugin"
sudo -H -u stack bash -c 'sudo yum install -y python-rdomanager-oscplugin' 
sudo -H -u stack bash -c 'sudo cp /usr/share/instack-undercloud/undercloud.conf.sample ~/undercloud.conf' 
chown -R stack.stack /home/stack/undercloud.conf
cd /home/stack

echo "Installing overcloud images"
sudo yum install -y rhosp-director-images rhosp-director-images-ipa
sudo -H -u stack bash -c 'sudo cp /usr/share/rhosp-director-images/overcloud-full-latest-8.0.tar ~/images/'
sudo -H -u stack bash -c 'sudo cp /usr/share/rhosp-director-images/ironic-python-agent-latest-8.0.tar ~/images/'
cd /home/stack/images
for tarfile in *.tar; do tar -xf $tarfile; done
chown -R stack.stack /home/stack/images

echo "Downgrading TripleO packages for Bug# 1347063"
#For time being downgrade TripleO client for this bug:
#https://bugzilla.redhat.com/show_bug.cgi?id=1347063
#KB Article: https://access.redhat.com/solutions/2446961
yum downgrade -y python-tripleoclient-0.3.4-4.el7ost.noarch openstack-tripleo-heat-templates-kilo-0.8.14-11.el7ost.noarch openstack-tripleo-heat-templates-0.8.14-11.el7ost.noarch

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
openstack-config --set undercloud.conf DEFAULT local_ip $LOCAL_IP
openstack-config --set undercloud.conf DEFAULT undercloud_public_vip  $UNDERCLOUD_PUBLIC_VIP
openstack-config --set undercloud.conf DEFAULT undercloud_admin_vip $UNDERCLOUD_ADMIN_VIP
openstack-config --set undercloud.conf DEFAULT local_interface $LOCAL_IFACE
openstack-config --set undercloud.conf DEFAULT masquerade_network $MASQUERADE_NETWORK
openstack-config --set undercloud.conf DEFAULT dhcp_start $DHCP_START
openstack-config --set undercloud.conf DEFAULT dhcp_end $DHCP_END
openstack-config --set undercloud.conf DEFAULT network_cidr $NETWORK_CIDR
openstack-config --set undercloud.conf DEFAULT network_gateway $NETWORK_GATEWAY
openstack-config --set undercloud.conf DEFAULT discovery_iprange $DISCOVERY_IP_START,$DISCOVERY_IP_END
openstack-config --set undercloud.conf DEFAULT discovery_runbench $DISCOVERY_RUNBENCH_BOOL
openstack-config --set undercloud.conf DEFAULT undercloud_debug $UNDERCLOUD_DEBUG_BOOL
openstack-config --set undercloud.conf DEFAULT image_path /home/stack/images
openstack-config --set undercloud.conf DEFAULT discovery_interface $DISCOVERY_INTERFACE

echo "Launch the following command as user STACK!"
echo "su - stack"
echo "screen"
echo "export HOSTNAME=$FQDN && openstack undercloud install"
echo "CTRL a d"

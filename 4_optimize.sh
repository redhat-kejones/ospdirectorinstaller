sudo openstack-config --set /etc/nova/nova.conf DEFAULT rpc_response_timeout 600
sudo openstack-config --set /etc/ironic/ironic.conf DEFAULT rpc_response_timeout 600

sudo sed -i 's/#\(max_concurrent_builds\).*/\1=4/' /etc/nova/nova.conf
sudo sed -i 's/#\(rpc_thread_pool_size\).*/\1=8/' /etc/ironic/ironic.conf
for i in $(sudo systemctl | awk '/ironic|nova/{print$1}'); do sudo systemctl restart $i; done

echo "Adding cron jobs to flush keystone and heat databases (from tuning the undercloud)"
sudo crontab -l > /tmp/file; sudo echo '0 04 * * * /bin/keystone-manage token_flush' >> /tmp/file; sudo crontab /tmp/file
sudo crontab -l > /tmp/file; sudo echo '0 04 * * * /bin/heat-manage purge_deleted -g days 1' >> /tmp/file; sudo crontab /tmp/file


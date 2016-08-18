sudo openstack-config --set /etc/nova/nova.conf DEFAULT rpc_response_timeout 600
sudo openstack-config --set /etc/ironic/ironic.conf DEFAULT rpc_response_timeout 600

sudo sed -i 's/#\(max_concurrent_builds\).*/\1=4/' /etc/nova/nova.conf
sudo sed -i 's/#\(rpc_thread_pool_size\).*/\1=8/' /etc/ironic/ironic.conf
for i in $(sudo systemctl | awk '/ironic|nova/{print$1}'); do sudo systemctl restart $i; done

echo "Adding cron jobs to flush keystone and heat databases (from tuning the undercloud)"
crontab -l > /root/file; echo '0 04 * * * /bin/keystone-manage token_flush' >> /root/file; crontab /root/file
crontab -l > /root/file; echo '0 04 * * * /bin/heat-manage purge_deleted -g days 1' >> /root/file; crontab /root/file


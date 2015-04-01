#!/bin/bash

TOP_DIR=$(cd $(dirname $0) && pwd)

ENVFILE=$TOP_DIR/env.sh
GOODIESFILE=$TOP_DIR/goodies.sh

source $ENVFILE
source $GOODIESFILE

echo "### delete wed01"
nova delete web01
echo "### delete app01"
nova delete app01
echo "### delete dbs01"
nova delete dbs01

wait_instance_delete web01
wait_instance_delete app01
wait_instance_delete dbs01

echo "### delete secgroups"
nova secgroup-delete sg-web-from-internet
nova secgroup-delete sg-all-from-app-net
nova secgroup-delete sg-all-from-dbs-net
nova secgroup-delete sg-all-from-console

echo "### delete step-server"
nova delete step-server
sleep 5

wait_instance_delete step-server

nova secgroup-delete sg-for-step-server

rm -f $HOME/.ssh/known_hosts

echo "### check status"
echo "## server list"
nova list
echo "## server list"
nova keypair-list
echo "## security group list"
nova secgroup-list
echo "## network list"
neutron net-list
echo "## router list"
neutron router-list
echo "## Floating IP list"
nova floating-ip-list
echo "### end script"

rm -vf get_net_id.sh
rm -vf sample_boot_*_server.sh
rm -vf userdata_*.txt

echo "=================================================="
echo "Cleanup completed!"
echo "=================================================="

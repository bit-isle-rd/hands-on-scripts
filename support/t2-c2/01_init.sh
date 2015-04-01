#!/bin/bash
# -*- coding: utf-8 -*-
#
# Description:
#   OpenStack Days Tokyo 2015の体験ラウンジで利用する仮想マシンを起動する
# Spec:
#   instance: {Username}-ansible-server
#   flavor: standard.xsmall
#   image: centos-base
#   keyname: default
#   secgroup: default
#   network: work-net
#

cd $(dirname $0)
TOP_DIR=$(pwd)

ENVFILE=env.sh
GOODIESFILE=goodies.sh

source $ENVFILE
source $GOODIESFILE

echo "Cleaning up..."
/opt/support/common/9_cleanup.sh

OS_STEPINSTANCE="${USER}-ansible-server"
OS_TESTINSTANCE="${USER}-test-server"
OS_FLAVOR=${FLAVOR_SMALL}
OS_IMAGE="centos-base"
OS_KEYNAME="default"
OS_SECGROUP="default"
OS_SECGROUP_FORSTEP="sg-for-ansible-server"
#OS_WORK_NET=`neutron net-show work-net | get_uuid`
OS_USERDATA="/opt/support/t2-c2/userdata/${USER}_userdata.txt"


echo "create secgroup"
nova secgroup-create ${OS_SECGROUP_FORSTEP} "secgroup for ansible server"
nova secgroup-add-rule ${OS_SECGROUP_FORSTEP} tcp 22 22 0.0.0.0/0
nova secgroup-add-rule ${OS_SECGROUP_FORSTEP} tcp 80 80 0.0.0.0/0
nova secgroup-add-rule ${OS_SECGROUP_FORSTEP} icmp -1 -1 0.0.0.0/0

echo ""
echo "Booting ${OS_STEPINSTANCE}..."
nova boot --flavor $OS_FLAVOR --image $OS_IMAGE \
--key-name $OS_KEYNAME --security-groups ${OS_SECGROUP},${OS_SECGROUP_FORSTEP} \
--user-data=$OS_USERDATA $OS_STEPINSTANCE
rc=$?
if [[ $rc -ne 0 ]]; then
    echo "boot error."
    exit 1
fi

echo ""
echo "Booting ${OS_TESTINSTANCE}..."
nova boot --flavor $OS_FLAVOR --image $OS_IMAGE \
--key-name $OS_KEYNAME --security-groups ${OS_SECGROUP},${OS_SECGROUP_FORSTEP} \
$OS_TESTINSTANCE
rc=$?
if [[ $rc -ne 0 ]]; then
    echo "boot error."
    exit 1
fi

echo ""
echo -n "Waiting for guest OS to be ready..."
wait_instance $OS_STEPINSTANCE private
while [[ true ]]; do
    sleep 10
    cons=$(nova console-log --length 1 ${OS_STEPINSTANCE} 2>/dev/null)
    echo "waiting to finish init "
    echo "recent console : $cons "
    if echo $cons | grep -q -E "ansible-server login:"; then
         break
    fi
done

STEPIP=`get_instance_ip $OS_STEPINSTANCE private`

echo ""
echo "Use the following command to login ${OS_STEPINSTANCE}"
echo "=> ssh -i $HOME/default.pem root@${STEPIP}"
echo ""

#
# [EOF]
#


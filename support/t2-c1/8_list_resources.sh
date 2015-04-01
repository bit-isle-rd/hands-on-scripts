#!/bin/bash

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

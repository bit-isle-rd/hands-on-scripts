#!/bin/bash

source ./env.sh

for i in `cat userlist.txt`
do
  source ${RCDIR}/adminrc
  keystone tenant-create --name $i
  keystone user-create --name $i --tenant $i --pass ${USERPASS}
  source ${RCDIR}/openrc_$i
  env|grep OS_
  read
  nova keypair-add --pub_key ${KEYDIR}/id_rsa.pub default
  nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
done 

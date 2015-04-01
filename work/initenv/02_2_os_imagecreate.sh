#!/bin/bash

source ./env.sh

# イメージが存在しない場合は下記から取得する
#wget https://obj.rdcloud.bi-rd.net/v1/AUTH_26da05131d0e432585610b37dcd0f9a5/os-base/work/initenv/centos-base.img --no-check-certificate


source ${RCDIR}/adminrc

glance image-create --container-format bare --disk-format qcow2 --file ./centos-base.img --name centos-base --is-public True

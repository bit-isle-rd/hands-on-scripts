#!/bin/bash

source ./env.sh

#mkdir -p ${KEYPATH}
#ssh-keygen -t rsa -f ${KEYPATH}/id_rsa -N "" -q -b 2048

for i in `cat userlist.txt`
do  
  sudo -u $i mkdir -p /home/$i/.ssh
  sudo -u $i cp -f ${KEYPATH}/authorized_keys /home/$i/.ssh/
  cp -f ${KEYPATH}/id_rsa /home/$i/.ssh/
  chown $i:students /home/$i/.ssh/id_rsa
  cp -f ${KEYPATH}/id_rsa /home/$i/default.pem
  chown $i:students /home/$i/default.pem
done

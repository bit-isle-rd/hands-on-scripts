#!/bin/bash

source ./env.sh

for i in `cat userlist.txt`
do  
  sudo -u $i cp -f ./.bash_profile /home/$i/
done

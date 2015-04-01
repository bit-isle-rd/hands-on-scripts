#!/bin/bash

function extract_line_with_uuid () {
   cat - | grep -v '\-\-\-' |grep -E [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}
}

function get_instance_uuid_list () {
   nova list | extract_line_with_uuid | awk '{print $2}'
}

function echo_run_cmd () {
   echo "\$ ${1:?}"
   ${1:?}
}

wait_instance_delete() {
    local name=${1:?}
    local interval=${2:-5}
    local timeout=${3:-600}

    local elapsed=0
    echo "check nova $name"
    while [ $timeout -ge 0 ]; do
        nova list | grep $name > /dev/null
        if [ $? -eq 1 ]; then
            echo "$name has been deleted."
            return
        fi
        echo "waiting to be deleted: $elapsed secs"
        timeout=`expr $timeout - $interval`
        elapsed=`expr $elapsed + $interval`
        sleep $interval
    done
    echo "$name has not been deleted in $timeout seconds!"
    exit 1
}

echo "### delete all instances"
servers=`get_instance_uuid_list`
for i in $servers
do
   echo "# delete instance: ${i}"
   nova delete ${i:?}
done

for i in $servers
do
   wait_instance_delete $i
done

echo "### delete all secgroups (exclude default)"
for i in `nova secgroup-list |grep -v " Id " |grep -v default | awk '{print $2}'`
do
   echo "# delete secgroup: ${i}"
   nova secgroup-delete ${i:?}
done

echo "### delete all keypairs (exclude default)"
for i in `nova keypair-list | grep -E "[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){15}" | grep -v default | awk '{print $2}'`
do
   echo "# delete keypair: ${i}"
   nova keypair-delete ${i:?}
done

echo "### delete all volumes-snapshots"
for i in `cinder snapshot-list | extract_line_with_uuid | awk '{print $2}'`
do
   echo "# delete snapshot: ${i}"
   cinder snapshot-delete ${i:?}
done


echo "### delete all volumes"
for i in `cinder list | extract_line_with_uuid | awk '{print $2}'`
do
   echo "# delete volume: ${i}"
   cinder delete ${i:?}
done



rm -f $HOME/.ssh/known_hosts
rm -rf $HOME/*
cp -p $HOME/.ssh/id_rsa $HOME/default.pem

echo "########## completed !!"


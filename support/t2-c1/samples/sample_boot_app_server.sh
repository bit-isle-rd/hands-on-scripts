get_instance_ip () {
  local name=${1:?}
  local net=${2:?}

  nova show $name | grep network | grep $net | cut -d '|' -f 3 | awk '{print $1}'
}

MY_DBS_IP=$(get_instance_ip dbs01 dbs-net)

. get_net_id.sh

nova boot \
    --flavor standard.xsmall \
    --image "centos-base" \
    --key-name default \
    --user-data userdata_app.txt \
    --security-groups sg-all-from-console,sg-all-from-app-net,sg-all-from-dbs-net \
    --availability-zone az1 \
    --nic net-id=${MY_APP_NET} \
    --nic net-id=${MY_DBS_NET} \
    --nic net-id=${MY_WORK_NET} \
    --meta dbs_ip=${MY_DBS_IP} \
    app01

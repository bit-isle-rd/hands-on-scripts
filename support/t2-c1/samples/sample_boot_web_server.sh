get_instance_ip () {
  local name=${1:?}
  local net=${2:?}

  nova show $name | grep network | grep $net | cut -d '|' -f 3 | awk '{print $1}'
}

MY_APP_IP=$(get_instance_ip app01 app-net)

. get_net_id.sh

nova boot \
    --flavor standard.xsmall \
    --image "centos-base" \
    --key-name default \
    --user-data userdata_web.txt \
    --security-groups sg-all-from-console,sg-web-from-internet,sg-all-from-app-net \
    --availability-zone az1 \
    --nic net-id=${MY_DMZ_NET} \
    --nic net-id=${MY_APP_NET} \
    --meta app_ip=${MY_APP_IP} \
    web01

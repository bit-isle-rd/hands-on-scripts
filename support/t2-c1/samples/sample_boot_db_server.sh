. get_net_id.sh

nova boot \
    --flavor standard.xsmall \
    --image "centos-base" \
    --key-name default \
    --user-data userdata_dbs.txt \
    --security-groups sg-all-from-console,sg-all-from-dbs-net \
    --availability-zone az1 \
    --nic net-id=${MY_DBS_NET} \
    --nic net-id=${MY_WORK_NET} \
    dbs01

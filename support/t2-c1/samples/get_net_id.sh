get_uuid () { cat - | grep " id " | awk '{print $4}'; }

get_instance_ip () {
  local name=${1:?}
  local net=${2:?}

  nova show $name | grep network | grep $net | cut -d '|' -f 3 | awk '{print $1}'
}

export MY_WORK_NET=`neutron net-show work-net | get_uuid`
export MY_DMZ_NET=`neutron net-show dmz-net  | get_uuid`
export MY_APP_NET=`neutron net-show app-net  | get_uuid`
export MY_DBS_NET=`neutron net-show dbs-net  | get_uuid`

echo "MY_WORK_NET=$MY_WORK_NET"
echo "MY_DMZ_NET=$MY_DMZ_NET"
echo "MY_APP_NET=$MY_APP_NET"
echo "MY_DBS_NET=$MY_DBS_NET"

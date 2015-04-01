function get_uuid () {
    cat - | grep " id " | awk '{print $4}'
}

function get_fixed_ip () {
    cat - | grep ${1:?} |grep -v from |grep -v sg | awk '{print $5}' | sed -e 's/,//'
}

function get_instance_ip () {
    local SERVER_NAME=${1:?}
    local LOCAL_NET_NAME=${2:?}

    nova show $SERVER_NAME | get_fixed_ip $LOCAL_NET_NAME
}

function wait_instance () {
    local SERVER_NAME=${1:?}
    local NETWORK_NAME=${2:?}
    local interval=${3:-5}
    local timeout=${4:-600}

    local elapsed=0
    echo "check $SERVER_NAME ACTIVE"
    while [ $timeout -ge 0 ]; do
        nova list | grep $SERVER_NAME | grep ACTIVE | grep $NETWORK_NAME > /dev/null
        if [ $? -eq 0 ]; then
            echo "$SERVER_NAME is now ACTIVE"
            return
        fi
        echo "waiting to become ACTIVE: $elapsed secs"
        timeout=`expr $timeout - $interval`
        elapsed=`expr $elapsed + $interval`
        sleep $interval
    done
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

function wait_ping_resp () {
    local TARGET=${1:?}
    local interval=${2:-5}
    local timeout=${3:-600}

    local elapsed=0
    echo "check ping response from $TARGET"
    while [ $timeout -ge 0 ]; do
        ping -c 1 $TARGET > /dev/null
        if [ $? -ne 1 ]; then
            return
        fi
        echo "wait ping response from $TARGET: $elapsed secs"
        timeout=`expr $timeout - $interval`
        elapsed=`expr $elapsed + $interval`
        sleep $interval
    done
}

function wait_sshd_active () {
    local TARGET=${1:?}
    local interval=${2:-5}
    local timeout=${3:-600}

    local elapsed=0
    echo "check sshd active on $TARGET"
    while [ $timeout -ge 0 ]; do
        ssh -i $HOME/default.pem -o StrictHostKeyChecking=no root@$TARGET hostname >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            return
        fi
        echo "wait sshd active on $TARGET: $elapsed secs"
        timeout=`expr $timeout - $interval`
        elapsed=`expr $elapsed + $interval`
        sleep $interval
    done
}

function wait_nova_console_log () {
    local name=${1:?}
    local message=${2:?}
    local interval=${3:-5}
    local timeout=${4:-600}

    local elapsed=0
    echo "check '$message' from console log of $name"
    while [ $timeout -ge 0 ]; do
        nova console-log --length 100 $name | grep "$message"
        if [ $? -eq 0 ]; then
            return
        fi
        echo "wait '$message' from console log of $name: $elapsed secs"
        timeout=`expr $timeout - $interval`
        elapsed=`expr $elapsed + $interval`
        sleep $interval
    done
}

function wait_yum_pip () {
    local TARGET=${1:?}
    local interval=${2:-5}
    local timeout=${3:-600}

    local YUMRETVAL=0
    local PIPRETVAL=0
    local elapsed=0

    echo "check yum and pip from $TARGET"
    while [ $timeout -ge 0 ]; do
        YUMRETVAL=`ssh -o 'StrictHostKeyChecking no' -i $HOME/default.pem root@${TARGET:?} 'ps -ef |grep -v grep |grep yum > /dev/null 2>&1;echo -n $?'`
        PIPRETVAL=`ssh -o 'StrictHostKeyChecking no' -i $HOME/default.pem root@${TARGET:?} 'ps -ef |grep -v grep |grep pip > /dev/null 2>&1;echo -n $?'`
        if [ $YUMRETVAL -ne 0 -a $PIPRETVAL -ne 0 ]; then
            return
        fi
        echo "wait to end yum or pip from $TARGET: $elapsed secs"
        timeout=`expr $timeout - $interval`
        elapsed=`expr $elapsed + $interval`
        sleep $interval
    done
}

wait_for_cinder() {
    local restype=${1:?}
    local name=${2:?}
    local status=${3:-available}
    local interval=${4:-5}
    local timeout=${5:-600}

    local cmd
    if [ "$restype" = "volume" ]; then
        cmd=list
    else
        cmd=$restype-list
    fi

    local elapsed=0
    echo "check cinder $restype from $name"
    while [ $timeout -ge 0 ]; do
        cinder $cmd | grep $name | grep $status > /dev/null
        if [ $? -eq 0 ]; then
            echo "$name is now $status."
            return
        fi
        echo "waiting to become $status: $elapsed secs"
        timeout=`expr $timeout - $interval`
        elapsed=`expr $elapsed + $interval`
        sleep $interval
    done
    echo "$name has not become $status in $timeout seconds!"
    exit 1
}

wait_for_cinder_delete() {
    local restype=${1:?}
    local name=${2:?}
    local interval=${3:-5}
    local timeout=${4:-600}

    local cmd
    if [ "$restype" = "volume" ]; then
        cmd=list
    else
        cmd=$restype-list
    fi

    local elapsed=0
    echo "check cinder $restype from $name"
    while [ $timeout -ge 0 ]; do
        cinder $cmd | grep $name > /dev/null
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

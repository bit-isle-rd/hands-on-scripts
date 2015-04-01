#!/bin/bash

cd $(dirname $0)
TOP_DIR=$(pwd)

ENVFILE=env.sh
GOODIESFILE=goodies.sh

source $ENVFILE
source $GOODIESFILE

/opt/support/common/9_cleanup.sh

echo "create secgroup"
nova secgroup-create sg-for-step-server "secgroup for step server"
nova secgroup-add-rule sg-for-step-server tcp 1 65535 ${STEPIP}/32
nova secgroup-add-rule sg-for-step-server icmp -1 -1 ${STEPIP}/32

#TMPDIR=`mktemp -d`
#cp -p $HOME/default.pem $TMPDIR/default.pem
#scp -pr -i $HOME/default.pem -o StrictHostKeyChecking=no $TMPDIR/* root@$STEP_SERVER_IP:
#rm -rf $TMPDIR

echo "create virtual networks for SNSapp"

echo "create secgroups"
nova secgroup-create sg-web-from-internet "for web"
nova secgroup-create sg-all-from-app-net  "for app"
nova secgroup-create sg-all-from-dbs-net  "for db"

nova secgroup-add-rule sg-web-from-internet tcp 80 80 0.0.0.0/0


cp -pr $TOP_DIR/samples/* $HOME

echo "============================================================"
echo "  Initialization Completed!"
echo "============================================================"

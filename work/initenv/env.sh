#!/bin/bash

export RCDIR=./rcfiles
export RCPRFIX=openrc_
export SUPPORTDIR=/opt/support/openrc

source ${RCDIR}/source_openrc
export USERPASS=${OS_PASSWORD}
export KEYDIR=./keys


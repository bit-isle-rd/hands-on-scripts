#!/bin/bash

source ./env.sh

rm -rf ${RCDIR}/${RCPRFIX}*

for i in `cat userlist.txt`
do
cp ${RCDIR}/source_openrc ${RCDIR}/${RCPRFIX}$i
sed -i s/XXXUSERXXX/$i/ ${RCDIR}/${RCPRFIX}$i
done 

rm -rf ${SUPPORTDIR}/*
cp ${RCDIR}/${RCPRFIX}* ${SUPPORTDIR}

#!/bin/bash

RCDIR=./rcfiles
source ${RCDIR}/adminrc

nova flavor-create m1.xsmall 6 1024 10 1

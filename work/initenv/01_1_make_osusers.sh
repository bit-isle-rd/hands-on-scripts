#!/bin/bash

groupadd students

for i in `cat userlist.txt`
do  
useradd -g students -m $i
done

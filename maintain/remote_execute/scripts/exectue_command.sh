#!/usr/bin/env bash

target_server=$1
if [ -n $target_server ]; then
    echo "target_server is null!"
    exit 1
fi

file=/data2/servers/${target_server}.config
if [ ! -f $file ]; then
    echo "$file is not exist!!"
    exit 1
fi


lan_ip=`cat $file | awk '{print $4}'`


ssh root@$lan_ip df
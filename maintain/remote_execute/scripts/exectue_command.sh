#!/usr/bin/env bash

target_server=$1
command=$2
if [ -n $target_server ]; then
    echo "target_server is null!"
    return 1
fi

if [ -n $comnand ]; then
    echo "command is null!"
    return 1
fi

file=/data2/servers/${target_server}.config
if [ ! -f $file ]; then
    echo "$file is not exist!!"
    return 1
fi


lan_ip=`cat $file | ask '{print $4}'`


ssh root@$lan_ip $command
#!/usr/bin/env bash
# -*-coding=utf8-*-
# @Auther: Yao Shuai 2019-05-23

servers=`java -jar batchserver.jar ${@:2}`

echo "all server list:"
echo "$servers"
echo "are you sure!!?[y/n]"

read confirm
if [ $confirm != "y" ]; then
    exit 1
fi

timestamp=`data`
for server in $servers
do
    if [ -f /data2/servers/${server}.config ]; then
        if [ ! -f ./logs ]; then
            mkdir -p ./logs
        fi
        sh $1 $server > logs/${server}_$1_$timestamp.log 2>&1 &
    fi
done
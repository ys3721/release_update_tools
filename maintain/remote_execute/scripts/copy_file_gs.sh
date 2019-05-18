#!/usr/bin/env bash

if [ -n $1 ]; then
    file="/data2/servers/$1.config"
    if [ ! -f $file ]; then
        echo "$file is not exist!!!"
        exit 1
    fi
    lan_ip=`cat $file | awk '{print $4}'`
    scp /data3/init_server/package/backup_mysql.py root@$lan_ip:/data0/
else
    echo "server config is null!"
    exit 1
fi

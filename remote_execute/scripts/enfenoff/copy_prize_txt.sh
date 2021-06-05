#!/bin/sh
if [ -n $1 ]; then
    file=/data2/servers/$1.config
    if [ ! -f $file ]; then
        echo '$file is not exist!!!'
        exit 1
    else
        config=`cat $file`
        lan_ip=`echo $config | awk '{print $4}'`
    fi
else
    echo "no server config file is assign !!"
    exit 1

fi

scp /data3/remote_execute/scripts/enfenoff/prizeChar2.txt root@$lan_ip:/data0/wg_script/logs/

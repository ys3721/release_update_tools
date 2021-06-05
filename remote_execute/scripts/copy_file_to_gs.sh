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

ssh root@lanip mkdir -p /data0/zeus/sadir/tools/
scp /data3/init_server/package/clean_game_log.sh root@$lan_ip:/data0/zeus/sadir/tools/
ssh root@$lan_ip sh /data0/zeus/sadir/tools/clean_game_log.sh


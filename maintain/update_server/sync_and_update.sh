#!/usr/bin/env bash

file=/data2/servers/$1.config
opt=$2
pidfile="pids/$1_pid"

if test -e $pidfile; then
    echo "$pidfile found, interrupted!"
    exit
fi

if [ ! -d "./pids" ]; then
    mkdir ./pids
fi
echo $$ > $pidfile

zipCount=`ls *.zip | wc -l`
if [ $zipCount -gt 1 ]; then
        echo "syn failed, multi zip file found!!!"
        exit 1
fi

if [ ! -f $file ]; then
    echo "config file $file not exist!"
    exit 1
fi

config=`cat $file`
server_id=`echo $config | awk '{print $1}'`
region_id=`echo $config | awk '{print $2}'`
domain=`echo $config | awk '{print $3}'`
lan_ip=`echo $config | awk '{print $4}'`
wan_ip=`echo $config | awk '{print $5}'`
server_name=`echo $config | awk '{print $6}'`
turnOnCenter=`echo $config | awk '{print $7}'`

ip=$lan_ip
echo $ip
#copying update_server.sh script to $ip
scp update_locate_server.sh root@$ip:/data0
scp /data3/init_server/package/deploy_current_path.sh root@$ip:/data0

#remove all old release files
ssh root@$ip "[ -d /data0 ] && rm /data0/*.zip"
ssh root@$ip "[ -d /data1 ] && rm /data1/*.zip"
ssh root@$ip "[ -d /data5 ] && rm /data5/*.zip"
ssh root@$ip "[ -d /data6 ] && rm /data6/*.zip"

#copying release file to $ip
scp *.zip root@$ip:/data0/
scp *.zip root@$ip:/data1/
scp *.zip root@$ip:/data5/
scp *.zip root@$ip:/data6/

sleep 4
#executing update script
ssh root@$ip "sh /data0/update_locate_server.sh $2"

rm -f $pidfile
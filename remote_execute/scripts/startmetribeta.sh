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

echo $lan_ip
echo $1.config
ssh $lan_ip "nohup /data0/metricbeat/metricbeat -e -c /data0/metricbeat/metricbeat.yml > /dev/null 2>&1 & ";

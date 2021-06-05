#!/usr/bin bash

if [ ! -n $1 ]; then
    exit 1
fi

file="/data2/servers/$1.config"
if [ ! -f $file ]; then
    exit 1
fi

lan_ip=`cat $file | awk '{print $4}'`

scp /data3/remote_execute/scripts/dragCost.jar root@$lan_ip:/data0/sql_bak/
ssh root@$lan_ip "cd /data0/sql_bak;export PATH=/data0/jdk7/usr/java/jdk1.7.0_15/bin:$PATH;java -cp ./dragCost.jar:/data0/wg_libs/mysql-connector-java-5.1.7-bin.jar cn.kaixin.bug.DragChargeCost 2020_05_15"

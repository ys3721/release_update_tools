#!/usr/bin bash

if [ ! -n $1 ]; then
    exit 1
fi

file="/data2/servers/$1.config"
if [ ! -f $file ]; then
    exit 1
fi

lan_ip=`cat $file | awk '{print $4}'`

scp /data3/remote_execute/scripts/*.jar root@$lan_ip:/data0/sql_bak/
ssh root@$lan_ip "export PATH=/data0/jdk7/usr/java/jdk1.7.0_15/bin:$PATH;java -cp /data0/sql_bak/finditem.jar:/data0/sql_bak/mysql-connector-java-5.1.7-bin.jar cn.kaixin.bug.LostItemsProbe"

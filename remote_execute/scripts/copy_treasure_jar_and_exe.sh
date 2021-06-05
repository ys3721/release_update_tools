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
ssh root@$lan_ip "cd /data0/sql_bak;export PATH=/data0/jdk7/usr/java/jdk1.7.0_15/bin:$PATH;java -cp ./finditem.jar:/data0/wg_libs/mysql-connector-java-5.1.7-bin.jar:/data0/wg_libs/json-lib-2.4-jdk15.jar:/data0/wg_libs/commons-lang-2.4.jar:/data0/wg_libs/ezmorph-1.0.6.jar:/data0/wg_libs/commons-logging-1.1.1.jar:/data0/wg_libs/commons-collections-3.2.1.jar:/data0/wg_libs/commons-beanutils-1.8.0.jar cn.kaixin.bug.FindItemGen"

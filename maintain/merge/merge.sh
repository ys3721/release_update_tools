# @Auther: Yao Shuai
#!/bin/bash

. /etc/init.d/functions

RED_COLOR='\E[1;31m'
GREEN_COLOR='\E[1;32m'
YELLOW_COLOR='\E[1;33m'
BLUE_COLOR='\E[1;34m'
RES='\E[0m'

export JAVA_HOME=/data0/jdk7/usr/java/jdk1.7.0_15
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH
export LC_ALL=zh_CN.GBK     # for linux: zh_CN
export LANG=zh_CN.GBK       # for linux: zh_CN

basepath=$(cd `dirname $0`; pwd)
merge_conf_file="${basepath}/merge_conf/merge.properties"
dos2unix ${merge_conf_file} >/dev/null 2>&1

var=`awk -F "=" '/svrIp/{print $2}' /data3/merge/merge_conf/merge.properties`
var=${var//:330?,/ }    #这里是将var中的,替换330x为空格
var=${var//:*/ }    #这里是将var中的,替换为空格


function check_java()
{
for ip in $var
do
    	java_num=`ssh root@$ip "ps -ef|grep -v grep|grep -c java"`
    	if [ ${java_num} -eq 0 ]
    	then
        	echo -e "${GREEN_COLOR}$ip gameserver and logserver is stop${RES}"
    	else
        	echo -e "${RED_COLOR}$ip gameserver and logserver is starting,please check !!!${RES}"
        	#exit 1
	fi
done

}

function checkmysql_bak(){
for ip in $var
do
    	ssh root@$ip "ls -lh /data0/sql_bak/*`date +%Y%m%d`*"
    	if [ $? -eq 0 ]
    	then
        	echo -e "${GREEN_COLOR}$ip MySQL backup is ok${RES}"
    	else
        	echo -e "${RED_COLOR}$ip MySQL backup is fail,please check!!!${RES}"
        	#exit 1
        fi
done

}

function check_all(){
check_java
checkmysql_bak
echo -e "${RED_COLOR}
1、/data3/merge/merge_conf/merge.properties is setup ok
2、gameserver and logserver is stop ok
3、MySQL backup is ok
${RES}"
echo "Are you sure?[y/n]"

read flag
if [ $flag != "y" ]; then
     echo "user quit!"
     exit 1
fi

}

start(){
        check_all
	ulimit -n 65535
	#find the jars
	jar_lib=`ls -1 /data0/wg_libs/*.jar`
	jar_lib=`echo $jar_lib | sed 's/ /:/g'`
	VELCP="merge.jar:merge_conf:$jar_lib"
	#init logs
	if [ ! -d 'logs' ] ; then  mkdir -p logs ; fi
	echo `$VELCP`
	java -cp $VELCP -Xmx9096M -Xms9096M -Xss160K -XX:NewRatio=2 -XX:PermSize=256m -XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC cn.kx.lj.merge.MergeMain > logs/merge.log
        echo "start merge"
}

case "$1" in
  start)
        start
        ;;
  *)
        echo -e "${GREEN_COLOR}Usage: $0 {start}${RES}"
        exit 1
esac

#!/usr/bin/env bash
<<!
 **********************************************************
 * Author        : Yao Shuai
 * Create time   : 2021-03-19 20:55
 * Description   : Quick sync update the game server
 * *******************************************************
!
a=$(java -jar ./batchserver.jar ${@:2})

for i in $a
do
  if [ -f /data2/servers/$i.config ]; then
    echo $i
  fi
done

echo "Are you sure? [y/n]"
read flag
if [ $flag != 'y' ]; then
  echo 'user quit...'
  eixt 1;
fi

for i in $a
do
  if [ -e "./pids/${i}_pid" ]; then
    >& 2 echo "server $i pid file exist! interrupted!!"
    exit 1
  fi
done

declare -A port2datax
port2datax=([3306]=0 [3307]=1 [3308]=5 [3309]=6)

for i in $a
do
  if [ -f "/data2/servers/${i}.config" ]; then
    ip=`cat /data2/servers/${i}.config | awk '{print $4}'`
    port=`cat /data2/servers/${i}.config | awk '{print $8}'`
    ssh root@${ip} "rm -f /data${port2datax[$port]}/wg_release_*.zip"
    scp ./wg_release*.zip root@${ip}:/data${port2datax[$port]}/

    #先停服  u更新db a启动
    _dir="/data${port2datax[$port]}"
    ssh root@${ip} "cd ${_dir}/wg_script/;chmod a+x ./gameserver_launch.sh;./gameserver_launch.sh stop"
    ssh root@${ip} "cd ${_dir}/wg_script/;chmod a+x ./logserver_launch.sh;./logserver_launch.sh stop"
    for j in {1..20}
    do
      sleep 2
      echo "Is stop server of $i ?"
      pcount=`ssh root@${ip} "ps -elf | grep -v grep | grep _server_$i | wc -l"`
      if [ $pcount -ne 0 ]; then
          echo "Server not stop of $i , Let me wait...."
      else
        echo "Server $i is stop !! ok."
        break
      fi
    done
    pcount=`ssh root@${ip} "ps -elf | grep -v grep | grep _server_$i" | wc -l`
    if [ $pcount -ne 0 ]; then
      echo "kill the server  $i brute !!!!!!!!"
      ssh root@${ip} "ps -elf | grep _server_$i | awk '{print $4}' | xargs kill"
       sleep 5
    fi

    ## 再更新
    ssh root@${ip} "unzip -oq $_dir/wg_release_*.zip -d $_dir"
    ssh root@${ip} "unzip -oq $_dir/wg_gameserver/server_lib.zip -d $_dir/wg_libs"
    ssh root@${ip} "unzip -oq $_dir/wg_gameserver/wg_resource.zip -d $_dir/wg_resources"
    ssh root@${ip} "rm -rf /${_dir}/wg_gameserver"
    ssh root@${ip} "mysql -uroot -p123456 -h127.0.0.1 -P${port} < ${_dir}/wg_sql/LogReasonsAutoGenerated.sql"
    if ssh root@${ip} [ -e "${_dir}/wg_sql/lj_db_update.sql" ]; then
      ssh root@${ip}  "mysql -uroot -p123456 -h127.0.0.1 -P$port -s -N -f < ${_dir}/wg_sql/lj_db_update.sql"
    fi

    ## 再启动
    if [[ $1 =~ a ]]; then
      ssh root@${ip} "cd ${_dir}/wg_script/;chmod a+x ./gameserver_launch.sh;./gameserver_launch.sh start"
      ssh root@${ip} "cd ${_dir}/wg_script/;chmod a+x ./logserver_launch.sh;./logserver_launch.sh start"
      echo "Begin Start server ok."
    else
      echo "Not argument whit [ a ], you must start the server manually!"
    fi
  fi

done

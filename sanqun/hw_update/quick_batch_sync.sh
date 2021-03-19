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

for i in $a
do
  if [ -f "/data2/servers/${i}.config" ]; then
    ip=`cat /data2/servers/${i}.config | awk '{print $4}'`
    port=`cat /data2/servers/${i}.config | awk '{print $8}'`
    echo $ip $port
  fi
done

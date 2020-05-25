#!/usr/bin/env bash
#Author yaoshuai @DATA 2020--5-25

servers_dir=/data2/servers/x*.config
ran_ips=""

for file_name in $servers_dir
do
  if [ -f $file_name ]
  then
    lip=$(awk '{print $4}' < $file_name)
    server_name=$(awk '{print $6}' < $file_name)
    if [[ $ran_ips =~ _${lip}_ ]]
    then
      continue
    fi
      ran_ips=_lip_$ran_ips
      echo "runing command -- $1 $server_name -- , wait...."
      sh $1 $server_name &
  fi
done

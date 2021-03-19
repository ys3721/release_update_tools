#!/usr/bin/bash
# -*-coding=utf8-*-
# @Auther: Yao Shuai

for file in 'ls | grep data'
do
  if [[ $file =~ "data" ]] && [[ $file =~ "data3" ]] && [[ $fie =~ "data2" ]]; then
    cd "/"$file/wg_script
    sh logserver_launch.sh stop
    sh gameserver_launch.sh stop
    sh logserver_launch.sh start
    sh gameserver_launch.sh start
  fi
done
#!/usr/bin/env bash
##Author        : Yao Shuai
##Create time   : 2021-07-22 21:15

function start() {
  sudo nohup ./ascension -env=test -service=login,msgq,game,fusion,agent >./stdout 2>&1 &
  pid=$!
  echo "$pid" > ./boot.pid
  sleep 8
  tail -n 50 ./stdout
  echo "go boot ${jarfile} Process Id:$pid begin running!已经更新成master最新，启动结束"
}

function stop(){
        pid=`cat ./boot.pid`
        echo "Stop GO Boot Process Id:$pid"
        sudo kill $pid
        rm -f ./boot.pid
        ps -elf |grep ascension| grep -v grep| awk '{print $4}'|xargs sudo kill
}

function copy_master() {
  rm -f ./ascension_*.tar.gz
  \cp -rf /data2/repo_share/ascension-server/build/ascension_*.tar.gz /data/ascension/
  cd /data/ascension/
  tar -xzvf ./ascension_*.tar.gz
}

stop
copy_master
start
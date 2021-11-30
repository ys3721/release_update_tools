#!/usr/bin/env bash
##Author        : Yao Shuai
##Create time   : 2021-07-22 21:15

function start() {
  if [ ! -f './ascension'  ];then
    echo '更新失败，没有编译成功.......更新失败，没有编译成功........'
  fi
  #nohup ./ascension -env=test -service=login,msgq,game,fusion,agent,debug >./logs/stdout 2>&1 &
  dlv --listen=:5432 --headless=true --api-version=2 --continue --accept-multiclient exec ./ascension -- -env=test -service=login,msgq,game,fusion,agent,debug >./logs/stdout 2>./logs/stderr &
  pid=$!
  echo "$pid" > ./boot.pid
  sleep 7
  tail -n 50 ./logs/stdout
  echo "go boot ${jarfile} Process Id:$pid begin running!已经更新成master最新，启动结束"
}

function stop(){
  pid=`cat ./boot.pid`
  echo "Stop GO Boot Process Id:$pid"
  sudo kill $pid
  rm -f ./boot.pid
  ps -elf |grep ascension| grep -v grep| awk '{print $4}'|xargs kill -9
  sleep 3
}

function copy_master() {
  rm -f ./ascension_*.tar.gz
  rm ./ascension
  \cp -rf /data2/repo_share/ascension-server/build/ascension_*.tar.gz /data/ascension/
  cd /data/ascension/
  tar -xzvf ./ascension_*.tar.gz
}

stop
copy_master
start
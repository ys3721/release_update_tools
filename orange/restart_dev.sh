#!/usr/bin/env bash
##Author        : Yao Shuai
##Create time   : 2021-10-12 21:15

function start() {
  cd /data/ascension-dev/
  if [ ! -f './ascension'  ];then
    echo '更新失败，没有编译成功.......'
  fi
  mv ./ascension ./ascdev
  \cp -r /data2/configs/dev/* /data/ascension-dev/assets/
  nohup ./ascdev -env=test -service=login,msgq,game,fusion,agent,debug >./logs/stdout 2>&1 &
  pid=$!
  echo "$pid" > ./boot.pid
  sleep 8
  tail -n 50 ./logs/stdout
  echo "go boot ${jarfile} Process Id:$pid begin running! 已经更新成Feature最新，启动结束"
}

function stop(){
  cd /data/ascension-dev/
  pid=`cat ./boot.pid`
  echo "Stop GO Boot Process Id:$pid"
  sudo kill $pid
  sleep 2
  rm -f ./boot.pid
  ps -elf |grep ascdev| grep -v grep| awk '{print $4}'|xargs kill -9
  sleep 3
}

function copy_dev() {
  cd /data/ascension-dev/
  rm -f ./ascension_*.tar.gz
  rm ./ascdev
  \cp -rf /data2/repo_share/dev-version/ascension-server/build/ascension_*.tar.gz /data/ascension-dev/
  cd /data/ascension-dev/
  tar -xzvf ./ascension_*.tar.gz
}

function compile() {
  cd /data2/repo_share/dev-version/ascension-server/
  git pull
  cd server
  sh ./build.sh test
  cd /data/ascension-dev/
}

compile
stop
copy_dev
start
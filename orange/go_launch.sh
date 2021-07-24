#!/usr/bin/env bash
##Author        : Yao Shuai
##Create time   : 2021-07-13 15:15

function start() {
  sudo nohup ./ascension -env=test -service=login,msgq,game,fusion,agent >./stdout 2>&1 &
  pid=$!
  echo "$pid" > ./boot.pid
  echo "go boot ${jarfile} Process Id:$pid maybe running!"
}

function stop(){
        pid=`cat ./boot.pid`
        echo "Stop GO Boot Process Id:$pid"
        sudo kill $pid
        rm -f ./boot.pid
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
      *)
        echo $"Usage: {start|stop}"
        exit 1
        ;;
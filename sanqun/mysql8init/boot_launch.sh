#!/usr/bin/env bash
<<!
 **********************************************************
 * Author        : Yao Shuai
 * Create time   : 2021-04-15 20:55
 * Description   : I don't know how to start the springboot
 *                 jar graceful.... so write it.
 * *******************************************************
!

function start() {
  export JAVA_HOME=/usr/local/jdk8/
  if [ ! -d ./logs ] ; then
    mkdir "./logs/"
  fi

  jarfile=$(ls *jar)
  java -Dapp.name=nppa-server -server -Xmx2048m -Xms2048m  -XX:NewRatio=2 -XX:SurvivorRatio=8 -XX:MaxTenuringThreshold=15 \
      -XX:ParallelGCThreads=8 -XX:ConcGCThreads=6 -XX:G1ReservePercent=10 -XX:InitiatingHeapOccupancyPercent=70 \
      -XX:+PrintGCDetails -Xloggc:./logs/gc.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./logs/dumpcrash.bin -XX:+UseG1GC -jar $jarfile >> ./logs/boot.log 2>&1 &
  pid=$!
  echo "$pid" > ./boot.pid
  echo "Sprintboot ${jarfile} Process Id:$pid maybe running!"
}

function stop(){
        pid=`cat ./boot.pid`
        echo "Stop Spring Boot Process Id:$pid"
        kill $pid
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
esac

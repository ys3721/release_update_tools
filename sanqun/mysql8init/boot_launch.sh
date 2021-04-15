#!/usr/bin/env bash
<<!
 **********************************************************
 * Author        : Yao Shuai
 * Create time   : 2021-04-15 20:55
 * Description   : I don't know how to star the springboot jar graceful....
 * *******************************************************
!

function foo() {
  export JAVA_HOME=/usr/local/jdk8/

  jarfile=${ls ./*.jar}
  java -Dapp.name=nppa-server -server -Xmx2048m -Xms2048m  -XX:NewRatio=2 -XX:SurvivorRatio=8 -XX:MaxTenuringThreshold=15 \
      -XX:ParallelGCThreads=8 -XX:ConcGCThreads=6 -XX:G1ReservePercent=10 -XX:InitiatingHeapOccpancyPercent=70 \
      -XX:+PrintGCDetails -XX:+UseG1GC -jar $jarfile >>./logs/$jarfile.std.log 2>$1 &
  pid=$!
  echo "$pid" > ./${jarfile}.pid
  echo "Sprintboot ./${jarfile} Process Id:$pid"
}

function stop(){
        pid=`cat ./${jarfile}.pid`
        echo "Stop Spring Boot Process Id:$pid"
        kill $pid
        rm -f ./${jarfile}.pid
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
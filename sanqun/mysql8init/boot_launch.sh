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

<<!
 **********************************************************
java -server -Xms1024m -Xmx1024m -XX:NewSize=256m \
     -XX:MaxNewSize=256m \
     -XX:+UseConcMarkSweepGC \
     -XX:CMSInitiatingOccupancyFraction=70
     -XX:+PrintGCDetails \
     -XX:+PrintGCDateStamps \
     -XX:+PrintTenuringDistribution \
     -Xloggc:logs/gc.log \
     -Djava.awt.headless=true
     -Dcom.sun.management.jmxremote -classpath ...

     1.7
     -Xms13g -Xmx13g -Xss512k -XX:PermSize=384m -XX:MaxPermSize=384m -XX:NewSize=12g -XX:MaxNewSize=12g
-XX:SurvivorRatio=18 -XX:MaxDirectMemorySize=2g -XX:+UseParNewGC -XX:ParallelGCThreads=4
-XX:MaxTenuringThreshold=15 -XX:+CMSParallelRemarkEnabled -XX:+CMSScavengeBeforeRemark -XX:+UseConcMarkSweepGC
-XX:+DisableExplicitGC -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70
-XX:+ScavengeBeforeFullGC -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=9
-XX:+CMSClassUnloadingEnabled  -XX:CMSInitiatingPermOccupancyFraction=70 -XX:+ExplicitGCInvokesConcurrent
-XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationConcurrentTime -XX:+PrintHeapAtGC
-Xloggc:/data/applogs/heap_trace.txt -XX:-HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/data/applogs/HeapDumpOnOutOfMemoryError

    1.8 but why not g1?
-Xms13g -Xmx13g -Xss512k -XX:MetaspaceSize=384m -XX:MaxMetaspaceSize=384m -XX:NewSize=11g -XX:MaxNewSize=11g -XX:SurvivorRatio=18\
 -XX:MaxDirectMemorySize=2g -XX:+UseParNewGC -XX:ParallelGCThreads=4 -XX:MaxTenuringThreshold=15 \
 -XX:+UseConcMarkSweepGC -XX:+DisableExplicitGC -XX:+UseCMSInitiatingOccupancyOnly -XX:+ScavengeBeforeFullGC \
 -XX:+CMSScavengeBeforeRemark -XX:+CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=70 \
 -XX:+CMSClassUnloadingEnabled -XX:SoftRefLRUPolicyMSPerMB=0 -XX:-ReduceInitialCardMarks -XX:+CMSClassUnloadingEnabled \
 -XX:+ExplicitGCInvokesConcurrent -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationConcurrentTime \
 -XX:+PrintHeapAtGC -Xloggc:/data/applogs/heap_trace.txt -XX:-HeapDumpOnOutOfMemoryError \
 -XX:HeapDumpPath=/data/applogs/HeapDumpOnOutOfMemoryError"
    try this:
-XX:PermSize=128m -XX:MaxPermSize=128m -XX:NewRatio=2 -XX:SurvivorRatio=8 -XX:MaxTenuringThreshold=15 -XX:+UseParallelOldGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -Xloggc:./logs/gc.log
 * *******************************************************
!


#!/bin/sh
# sh new_batch_server.sh new_example_batch_command.sh h1-h50 /data2/servers true (ip去重)
# sh new_batch_server.sh new_example_batch_command.sh h1-h50 /data2/servers false (ip不去重复)
ip="$1"
echo "执行中"$ip
ssh $ip "ls";

#!/usr/bin/env bash
server_count=`ls -lh / | egrep "data[0-1|5-6]$" | wc -l`
process_count=`ps -elf | grep GameServer | grep -v grep | wc -l`

echo $server_count
echo $process_count
if [ $server_count -ne $process_count ]; then
    python sms.py 13126888320 "紧急【三群-玩吧-h5-t1或t2】服务器异常，服务器已经异常停止！请检查！"
    python sms.py 15811302052 "紧急【三群-玩吧-h5 t1 or t2】服务器异常，服务器已经异常停止！请检查！"
    python sms.py 13212777262 "紧急【三群-玩吧-h5】服务器异常，服务器已经异常停止！请检查！"
fi

df |grep /dev/ | awk '{print $5}'
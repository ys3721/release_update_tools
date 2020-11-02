#!/usr/bin/env bash
#Auther yao shuai @Data 2020-05-23

function fileExist() {
  if [ ! -f "$1" ]
    then
      echo "file is not exist " "$1"
      return 1
    else
      return 0
  fi
}
fileExist /data3/update_server/maintain.state
existFile=$?
fileExist /data2/servers/$1.config
existFile2=$?
if [ $existFile -eq 1 ] || [ $existFile2 -eq 1 ]
  then
    exit 0
fi

maintain=$(awk '{print $1}' </data3/update_server/maintain.state)
if [ $maintain -eq 1 ]
then
  echo "GameServer is maintaining, ignore check!"
  exit 0
fi

ip=$(awk '{print $4}' < /data2/servers/"$1".config )
server_count=`ssh -o ConnectTimeout=5 $ip 'ls -lh / | egrep "data[0-1|5-6]$" | wc -l'`
process_count=`ssh -o ConnectTimeout=5 $ip 'ps -elf | grep GameServer | grep -v grep | wc -l'`

if [[ $server_count =~ "Connection timed out" ]] || [[ $process_count =~ "Connection timed out" ]]
then
  server_count=-1;
fi

for port in `seq 3306 3309`
do
  merged=`ssh -o ConnectTimeout=5 $ip "/usr/local/mysql/bin/mysql -uroot -p123456 -h127.0.0.1 -P$port -N  wg_lj -e'select battleFieldVersion from t_sys_info'"`
  if [ -n "$merged" ] && [ $merged -eq 4 ]
  then
    server_count=$((server_count - 1))
  fi
done
echo The server need server count is $server_count , ps count is $process_count .

if [[ "$server_count" != "$process_count" ]] && [ $server_count -ne $process_count ]
  then
    echo "$1所在的服务器好像是有机器挂了 The server need server count is $server_count , ps count is $process_count ."
    python /data3/remote_execute/scripts/monitor/sms.py 15811302052 "$1所在的服务器好像是有机器挂了 The server need server count is $server_count , ps count is $process_count ."
fi
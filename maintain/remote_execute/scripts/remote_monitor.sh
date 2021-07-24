#!/usr/bin/env bash
#Auther yao shuai @Data 2020-05-23

ip=$(awk '{print $4}' < /data2/servers/"$1".config )
server_count=`ssh $ip 'ls -lh / | egrep "data[0-1|5-6]$" | wc -l'`
process_count=`ssh $ip 'ps -elf | grep GameServer | grep -v grep | wc -l'`

for port in `seq 3306 3309`
do
  merged=`ssh $ip "/usr/local/mysql/bin/mysql -uroot -p123456 -h127.0.0.1 -P$port -N  wg_lj -e'select battleFieldVersion from t_sys_info'"`
  echo $merged
  if test $merged -eq 4
  then
    echo "Merged!!"
    server_count=$((server_count - 1))
  fi
done
echo The server need server count is $server_count

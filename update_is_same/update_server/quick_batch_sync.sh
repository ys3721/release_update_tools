a=`java -jar ./batchserver.jar ${@:2}`

ehco 1 > /data3/update_server/maintain.state
while getopts "a" args
do
  case $arg in
  a)
    echo 0 > /data3/update_server/maintain.state
    ;;
  esac
done
echo "all servers list:"
for i in $a
do
    if [ -f /data2/servers/$i.config ]
    then
        echo "$i"
    else
        continue
    fi
done
echo "Are you sure?[y/n]"
read flag
if [ $flag != "y" ]; then
	echo "user quit!"
        exit 1
fi

echo "parameters: $1"
echo "Are you sure?[y/n]"
read flag
if [ $flag != "y" ]; then
	echo "user quit!"
        exit 1
fi

for i in $a
do
	if test -e "pids/${i}_pid"; then
		>&2 echo "server $i pid file exist! interrupted!!"
		exit;
	fi
done

timestamp=`date +%Y%m%d%H%M%S`

if [ ! -d "./logs" ]; then
    mkdir ./logs/
fi

ran_ips=""
for i in $a
do
	if test -f "/data2/servers/${i}.config"; then
	    ip=`cat /data2/servers/${i}.config | awk '{print $4}'`
        if [[ ${ran_ips} =~ _${ip}_ ]]; then
            echo "executing then ip = $ip sync.sh $i $1 > logs/*_update_${ip}.log"
            continue
        fi
		echo "executing for ip = $ip sync.sh $i $1 > logs/${i}_update_${ip}.log"
        sh sync_and_update.sh $i $1 > logs/${i}_update_${ip}.log 2>&1 &
		ran_ips=$ran_ips"_"$ip"_"
	else
		continue;
	fi
done

#!/bin/sh
a=`java -jar batchserver.jar ${@:2}` 

echo "all servers list:"
echo "$a"
echo "Are you sure?[y/n]"
echo $1
read flag
if [ $flag != "y" ]; then
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

for i in $a
do
	replace_file_name=`echo $1 | sed -e "s/\//_/g"`
	echo "executing $1 $i > logs/${i}_${replace_file_name}_${timestamp}"
	sh $1 $i > logs/${i}_${replace_file_name}_${timestamp}.log 2>&1 &
	echo $! > pids/${i}_pid
done


#!/bin/sh
a=`java -jar batchserver.jar ${@:2}`

echo "all servers list:"
echo "$a"
echo "Are you sure?[y/n]"

read flag
if [ $flag != "y" ]; then
        exit 1
fi

for i in $a
do
    echo "executing $1 $i"
    sh $1 $i
done

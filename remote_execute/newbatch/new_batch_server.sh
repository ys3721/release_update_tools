#!/usr/bin/env bash
echo ${@:2}
a=`java -jar batchcommand.jar ${@:2}`
echo "$a"
echo "all servers list:"
echo "$a"
echo "Are you sure?[y/n]"

read conform
if [ $conform != "y" ]; then
    exit 1
fi

for i in $a
do
    echo "executing $1 $i"
    sh $1 $i
done

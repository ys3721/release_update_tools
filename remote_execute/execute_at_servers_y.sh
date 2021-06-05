#!/bin/sh
a=`java -jar batchserver.jar ${@:2}`

flag=y
if [ $flag != "y" ]; then
        exit 1
fi

for i in $a
do
    sh $1 $i
done

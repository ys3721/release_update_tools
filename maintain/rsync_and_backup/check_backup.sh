#!/bin/sh

FILE_PATH='/data0/backup/'
YESTERDAY=`date +%Y%m%d -d "0 days ago"`

filelist=`ls ${FILEPATH}${YESTERDAY}_*`
remote_ip="119.29.168.33"
role_name="my-sgqy-cn"
for file in $filelist
do
    if [ -f $file ]; then
        FILE_SIZE=`du $file | awk '{print $1}'`
        FILE_SIZE=`expr $FILE_SIZE / 1024`
        ipa=${file#*_}
        ip=${ipa%%_*}

        echo "bkrep : ${YESTERDAY} | ${ip} = "
        echo "role=${role_name}&date=${YESTERDAY}&file_name=${file}&file_size=${FILE_SIZE}&ip=${ip}&remote_ip=${remote_ip}"
        curl -G -d "role=${role_name}&date=${YESTERDAY}&file_name=${file}&file_size=${FILE_SIZE}&ip=${ip}&remote_ip=${remote_ip}" https://op.kaixin001.com/api/v1_insertbackup
        echo ""
        sleep 1s
    fi
done
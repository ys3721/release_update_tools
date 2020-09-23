#!/bin/sh
if [ -n $1 ]; then
        file=/data2/servers/$1.config
        if [ ! -f $file ]; then
                #echo "file $file not exist!!!"
                exit 1
        fi
        config=`cat $file`
        server_id=`echo $config | awk '{print $1}'`
        region_id=`echo $config | awk '{print $2}'`
        domain=`echo $config | awk '{print $3}'`
        lan_ip=`echo $config | awk '{print $4}'`
        wan_ip=`echo $config | awk '{print $5}'`
        server_name=`echo $config | awk '{print $6}'`
        turnOnCenter=`echo $config | awk '{print $7}'`
else
        #echo "no server config file profided!"
        exit 1
fi

ssh $lan_ip "sed -i 's/\"2560\"/\"2304\"/g' /data0/wg_deploy/deploy_config_$server_name.xml";
ssh $lan_ip "sed -i 's/\"2560\"/\"2304\"/g' /data1/wg_deploy/deploy_config_$server_name.xml";
ssh $lan_ip "sed -i 's/\"2560\"/\"2304\"/g' /data5/wg_deploy/deploy_config_$server_name.xml";
ssh $lan_ip "sed -i 's/\"2560\"/\"2304\"/g' /data6/wg_deploy/deploy_config_$server_name.xml";

ssh $lan_ip "sed -i 's/\"512\"/\"448\"/g' /data0/wg_deploy/deploy_config_$server_name.xml";
ssh $lan_ip "sed -i 's/\"512\"/\"448\"/g' /data1/wg_deploy/deploy_config_$server_name.xml";
ssh $lan_ip "sed -i 's/\"512\"/\"448\"/g' /data5/wg_deploy/deploy_config_$server_name.xml";
ssh $lan_ip "sed -i 's/\"512\"/\"448\"/g' /data6/wg_deploy/deploy_config_$server_name.xml";
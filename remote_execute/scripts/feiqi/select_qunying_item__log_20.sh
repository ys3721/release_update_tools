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

ssh $lan_ip "/usr/local/mysql/bin/mysql -uroot -P3306 -p123456 -h127.0.0.1 wg_lj_log -N -A -e \"select char_id,char_name,template_id,count from item_gen_log_2020_03_20 where reason = 287 and template_id in (96,1004);\"";
ssh $lan_ip "/usr/local/mysql/bin/mysql -uroot -P3307 -p123456 -h127.0.0.1 wg_lj_log -N -A -e \"select char_id,char_name,template_id,count from item_gen_log_2020_03_20 where reason = 287 and template_id in (96,1004);\"";
ssh $lan_ip "/usr/local/mysql/bin/mysql -uroot -P3308 -p123456 -h127.0.0.1 wg_lj_log -N -A -e \"select char_id,char_name,template_id,count from item_gen_log_2020_03_20 where reason = 287 and template_id in (96,1004);\"";
ssh $lan_ip "/usr/local/mysql/bin/mysql -uroot -P3309 -p123456 -h127.0.0.1 wg_lj_log -N -A -e \"select char_id,char_name,template_id,count from item_gen_log_2020_03_20 where reason = 287 and template_id in (96,1004);\"";
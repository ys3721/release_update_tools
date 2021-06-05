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

ssh $lan_ip "/usr/local/mysql/bin/mysql -uroot -p123456 -h127.0.0.1 wg_lj -A -e \"select charId, templateId, count(id) as c from t_item group by charId having c > 16 and templateId in (20025,20026,20027,20028);\"";
ssh $lan_ip "/usr/local/mysql/bin/mysql -uroot -p123456 -h127.0.0.1 -P3307 wg_lj -A -e \"select charId, templateId, count(id) as c from t_item group by charId having c > 16 and templateId in (20025,20026,20027,20028);\"";
ssh $lan_ip "/usr/local/mysql/bin/mysql -uroot -p123456 -h127.0.0.1 -P3308 wg_lj -A -e \"select charId, templateId, count(id) as c from t_item group by charId having c > 16 and templateId in (20025,20026,20027,20028);\"";
ssh $lan_ip "/usr/local/mysql/bin/mysql -uroot -p123456 -h127.0.0.1 -P3309 wg_lj -A -e \"select charId, templateId, count(id) as c from t_item group by charId having c > 16 and templateId in (20025,20026,20027,20028);\"";

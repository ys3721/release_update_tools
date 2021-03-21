#! /usr/bin/bash
# -*-coding=utf8-*-
# @Auther: Yao Shuai
source ./echo_util.sh

GAME_ID=5614
LOCAL_CENTER_IP="123.207.245.161"

# 定义的数据库用户名和密码
declare -A db_password_config
DB_PASSWORD_CONFIG=([sys_user]=root [sys_password]=123456 \
                    [game_user]=root [game_password]=123456 \
                    [gm_user]=gmroot [gm_password]=12345600)

# 定义java堆内存大小 然后没用 我只是试试这个循环的语法
declare -A memory_configs
declare -A memory_config
memory_config["game_server_memory"]=8096
memory_config["log_server_memory"]=1024
i=1
for key in "${!memory_config[@]}";do
  memory_configs[$i,$key]=${memory_config[$key]}
done
memory_config["game_server_memory"]=4096
memory_config["log_server_memory"]=819
((i++))
for key in "${!memory_config[@]}";do
  memory_configs[$i,$key]=${memory_config[$key]}
done
memory_config["game_server_memory"]=3072
memory_config["log_server_memory"]=512
((i++))
for key in "${!memory_config[@]}";do
  memory_configs[$i,$key]=${memory_config[$key]}
done
memory_config["game_server_memory"]=2304
memory_config["log_server_memory"]=248
((i++))
for key in "${!memory_config[@]}";do
  memory_configs[$i,$key]=${memory_config[$key]}
done

# 定义各种常亮，思路是约定大于配置
declare -A port2datax
port2datax=([3306]=0 [3307]=1 [3308]=5 [3309]=6)
declare -A port2log_port
port2log_port=([3306]=8083 [3307]=8007 [3308]=8008 [3309]=8009)
declare -A port2game_port
port2game_port=([3306]=8080 [3307]=8307 [3308]=8308 [3309]=8309)
declare -A port2telnet_port
port2telnet_port=([3306]=7000 [3307]=7307 [3308]=7308 [3309]=7309)
declare -A port2exr_port
port2exr_port=([3306]=6306 [3307]=6307 [3308]=6308 [3309]=6309)

rsync_ip="192.168.0.30"
#-------------- 欢乐的常量定义完毕 ----------------------------

## s1592.config格式：9655 1 s1592.qyz.feidou.com 10.10.6.195 119.29.150.151 s1592 true 3306
function read_config() {
    server_file_name=$1
    echo_info "Begin read config of server name = "$server_file_name" now......."
    ## s1592.config格式：9655 1 s1592.qyz.feidou.com 10.10.6.195 119.29.150.151 s1592 true 3306
    file_content=`cat /data2/servers/${server_file_name}.config`
    echo_debug "[Debug]$file_content"
    export SERVERID_CFG=`echo $file_content | awk '{print $1}'`
    export DOMAIN_CFG=`echo $file_content | awk '{print $3}'`
    export DOMAIN_PREFIX_CFG=`echo $DOMAIN_CFG | awk 'BEGIN{FS="."} {print $1}'`
    export LANIP_CFG=`echo $file_content | awk '{print $4}'`
    export WANIP_CFG=`echo $file_content | awk '{print $5}'`
    export SERVERNAME_CFG=`echo $file_content | awk '{print $6}'`
    export DB_PORT_CFG=`echo $file_content | awk '{print $8}'`
    echo_debug "[Debug]Read config file finish, $SERVERID_CFG  $DOMAIN_CFG $DOMAIN_PREFIX_CFG $LANIP_CFG \
    $WANIP_CFG $SERVERNAME_CFG ${DB_PORT_CFG}"
}

function generate_deploy_config() {
    echo_info "Begin generate config of server name=${SERVERNAME_CFG}${DB_PORT_CFG}now......."
    _db_port=${DB_PORT_CFG}
    #------------------ 生成game server config .js文件 --------------
    server_config_file=./generated/${SERVERNAME_CFG}_game_server.cfg.js
    \cp ./template/game_server.cfg.js.template $server_config_file
    #需要替换的字符串 #domain# #data_path# #mysql_port# #server_id# #server_name# #log_port# #game_port# #telnet_port#
    sed -i "s/#domain#/$DOMAIN_CFG/g" $server_config_file
    sed -i "s/#data_path#/\\/data${port2datax[$_db_port]}/g" $server_config_file
    sed -i "s/#server_id#/$SERVERID_CFG/g" $server_config_file
    sed -i "s/#server_name#/$SERVERNAME_CFG/g" $server_config_file
    sed -i "s/#log_port#/${port2log_port[$_db_port]}/g" $server_config_file
    sed -i "s/#game_port#/${port2game_port[$_db_port]}/g" $server_config_file
    sed -i "s/#telnet_port#/${port2telnet_port[$_db_port]}/g" $server_config_file

    #------------------ 生成log server config .js文件 --------------
    echo_debug "[Debug]Begin generate config of LOG SEVER name = $SERVERNAME_CFG $DB_PORT_CFG now......."
    log_config_file=./generated/${SERVERNAME_CFG}_log_server.cfg.js
    \cp ./template/log_server.cfg.js.template $log_config_file
    #需要替换的字符串 #server_name# #wan_ip# #domain# #log_port# #lan_ip# #log_telnet_port#
    sed -i "s/#server_name#/$SERVERNAME_CFG/g" $log_config_file
    sed -i "s/#wan_ip#/$WANIP_CFG/g" $log_config_file
    sed -i "s/#domain#/$SERVERNAME_CFG/g" $log_config_file
    sed -i "s/#log_port#/${port2log_port[$_db_port]}/g" $log_config_file
    sed -i "s/#lan_ip#/$LANIP_CFG/g" $log_config_file
    sed -i "s/#server_id#/$SERVERID_CFG/g" $log_config_file

    #------------------ 生成game sever launch 脚本文件 --------------
    echo "Begin generate $i 的server launch script sh ...=$SERVERID_CFG $DOMAIN_CFG $LANIP_CFG $WANIP_CFG $SERVERNAME_CFG"
    launch_server_file=./generated/${SERVERNAME_CFG}_gameserver_launch.sh
    \cp ./template/launch.sh.server.template $launch_server_file
    #需要替换的字符串 #server_name# #wan_ip# #domain# #log_port# #lan_ip# #log_telnet_port#
    sed -i "s/#server_name#/$SERVERNAME_CFG/g" $launch_server_file
    sed -i "s/#wan_ip#/$WANIP_CFG/g" $launch_server_file
    sed -i "s/#log_port#/${port2log_port[$_db_port]}/g" $launch_server_file
    sed -i "s/#lan_ip#/$LANIP_CFG/g" $launch_server_file
    sed -i "s/#server_id#/$SERVERID_CFG/g" $launch_server_file

    #------------------ 生成log sever launch 脚本文件 --------------
    echo "Begin generate $i log launch sh script...=$SERVERID_CFG $DOMAIN_CFG $LANIP_CFG $WANIP_CFG $SERVERNAME_CFG"
    launch_log_file=./generated/${SERVERNAME_CFG}_logserver_launch.sh
    \cp ./template/launch.sh.log.template $launch_log_file
    #需要替换的字符串 #server_name# #wan_ip# #domain# #log_port# #lan_ip# #log_telnet_port#
    sed -i "s/#server_name#/$SERVERNAME_CFG/g" $launch_log_file
    sed -i "s/#server_id#/$SERVERID_CFG/g" $launch_log_file

    #------------------ 生成 gmserver的 db1下xml文件 --------------
    echo "Begin generate $i gm config xml...=$SERVERID_CFG $DOMAIN_CFG $LANIP_CFG $WANIP_CFG $SERVERNAME_CFG"
    gm_xml_file=./generated/${SERVERNAME_CFG}_db.xml
    \cp ./template/gm_db.xml.template $gm_xml_file
     #需要替换的字符串 #server_name# #wan_ip# #domain# #log_port# #lan_ip# #log_telnet_port#
    sed -i "s/#server_name#/$SERVERNAME_CFG/g" $gm_xml_file
    sed -i "s/#wan_ip#/$WANIP_CFG/g" $gm_xml_file
    sed -i "s/#domain#/$DOMAIN_CFG/g" $gm_xml_file
    sed -i "s/#log_port#/${port2log_port[$_db_port]}/g" $gm_xml_file
    sed -i "s/#lan_ip#/$WANIP_CFG/g" $gm_xml_file
    sed -i "s/#server_id#/$SERVERID_CFG/g" $gm_xml_file
    sed -i "s/#mysql_port#/$_db_port/g" $gm_xml_file
    sed -i "s/#telnet_port#/${port2telnet_port[$_db_port]}/g" $gm_xml_file

    #------------------ 生成 gameserverd的 hibernate.properties 文件 --------------
    echo "Begin generate $i gs hibernate properties...=$SERVERID_CFG $DOMAIN_CFG $LANIP_CFG $WANIP_CFG $SERVERNAME_CFG"
    hibernate_properties_file=./generated/${SERVERNAME_CFG}_hibernate.properties
    \cp ./template/hibernate.properties.template $hibernate_properties_file
    sed -i "s/#mysql_port#/$_db_port/g" $hibernate_properties_file

    #------------------ 生成 logerver's jdbc.properties 文件 --------------
    echo "Begin generate $i logerver jdbc properties...=$SERVERID_CFG $DOMAIN_CFG $LANIP_CFG $WANIP_CFG $SERVERNAME_CFG"
    jdbc_properties_file=./generated/${SERVERNAME_CFG}_jdbc.properties
    \cp ./template/jdbc.properties.template $jdbc_properties_file
    sed -i "s/#mysql_port#/$_db_port/g" $jdbc_properties_file

}

init_empty_cloud_service() {
  echo_info "Will Init empty server of ${WANIP_CFG}"
  if ssh root@${WANIP_CFG} [ -d "/data0" ] || ssh root@${WANIP_CFG} [ -d "/var/lib/mysql" ]; then
    echo_err "NOT EMPTY SERVER , DONOT need init "
    return
  fi

  mount_data0=`ssh root@${WANIP_CFG} mount | grep data0 |wc -l`
  if [ $mount_data0 -ne 0 ]; then
    echo_err "NOT UN MOUNT , DONOT need mount disk "
    return
  fi

  disk_count=`ssh root@${WANIP_CFG} fdisk -l | grep /dev/vdb | wc -l`
  if [ $disk_count -eq 0 ];then
    echo "NO data disk , skip fdisk ~~~~"
  else
    ssh root@${WANIP_CFG} echo "n
    p
    1


    w
    " | fdisk /dev/vdb && mkfs -t ext4 /dev/vdb1 && mkdir /data0 && mount /dev/vdb1 /data0
  fi
  ssh root@${WANIP_CFG} df -TH
  if [ `ssh root@${WANIP_CFG} "echo /etc/fstab | grep swap | wc -l"` -ne 0 ]; then
    ssh root@${WANIP_CFG} "dd if=/dev/zero of=/swapfile bs=4M count=2000"
    ssh root@${WANIP_CFG} "mkswap /swapfile;swapon /swapfile"
    ssh root@${WANIP_CFG} 'echo "/swapfile swap swap defaults 0 0" >>/etc/fstab'
    ssh root@${WANIP_CFG} "mount -a;free"
  fi
  ssh root@${WANIP_CFG} "mkdir -p /data0/src"
  echo_info "Init server of ${WANIP_CFG} Finish!!"
}

send_config_files() {
  _s_name=$SERVERNAME_CFG
  _dir="/data${port2datax[$DB_PORT_CFG]}"
  echo_info "Begin copy the config to server $_s_name......$_dir"
  ssh root@${WANIP_CFG} "rm -rf ${_dir}/wg_config/*"
  ssh root@${WANIP_CFG} "mkdir -p ${_dir}/wg_config/game_server_config ${_dir}/wg_config/log_server_config \
    ${_dir}/wg_libs ${_dir}/wg_resources ${_dir}/wg_script"
  scp ./generated/${_s_name}_game_server.cfg.js root@${WANIP_CFG}:$_dir/wg_config/game_server_config/game_server.cfg.js
  scp ./generated/${_s_name}_hibernate.properties root@${WANIP_CFG}:$_dir/wg_config/game_server_config/hibernate.properties
  scp ./template/nomodify/log4j.properties.server.template root@${WANIP_CFG}:$_dir/wg_config/game_server_config/log4j.properties

  scp ./generated/${_s_name}_log_server.cfg.js root@${WANIP_CFG}:$_dir/wg_config/log_server_config/log_server.cfg.js
  scp ./generated/${_s_name}_jdbc.properties root@${WANIP_CFG}:$_dir/wg_config/log_server_config/jdbc.properties
  scp ./template/nomodify/log4j.properties.log.template root@${WANIP_CFG}:$_dir/wg_config/log_server_config/log4j.properties

  scp ./generated/${_s_name}_gameserver_launch.sh root@${WANIP_CFG}:$_dir/wg_script/gameserver_launch.sh
  scp ./generated/${_s_name}_logserver_launch.sh root@${WANIP_CFG}:$_dir/wg_script/logserver_launch.sh

  echo_info "Finish copy the config to server $_s_name......"
  scp ./generated/${SERVERNAME_CFG}_db.xml root@${LOCAL_CENTER_IP}:/data0/wg_gmserver/WEB-INF/classes/conf/db1/

  center_xml_path=/data0/wg_center/WEB-INF/classes/gameserver.xml
  match_content=serverID\="${SERVERID_CFG}"
  echo_debug $match_content
  have_count=$(ssh root@${LOCAL_CENTER_IP} sed -n /${match_content}/p ${center_xml_path} | wc -l)
  echo_debug ${have_count}---------------
  if [ $have_count -eq 0 ]; then
    ssh root@${LOCAL_CENTER_IP} "sed -i 's#</servers>#\t<server ip=\"${WANIP_CFG}\" port=\"${port2telnet_port[${DB_PORT_CFG}]}\" gameID=\"5614\" serverID=\"${SERVERID_CFG}\"/>\t\n</servers>#g' $center_xml_path"
    else
    echo_err "当前中心服已经有这个服务器的配置了，注意不会覆盖！"
  fi
}

deploy_server() {
  echo_info "Begin deploy server......."
  _dir="/data${port2datax[$DB_PORT_CFG]}"
  ssh root@${WANIP_CFG} "rm -rf /${_dir}/wg_resources/*"
  ssh root@${WANIP_CFG} "rm -rf /${_dir}/wg_libs/*"
  ssh root@${WANIP_CFG} "rm -rf /${_dir}/wg_script/logs"

  scp /data3/update_server/wg_release_*.zip root@${LANIP_CFG}:${_dir}/
  #ssh root@${WANIP_CFG} "rsync -av ${rsync_ip}::download/wg_release*.zip /${_dir}/"
  ssh root@${WANIP_CFG} "unzip -oq $_dir/wg_release_*.zip -d $_dir"
  ssh root@${WANIP_CFG} "unzip -oq $_dir/wg_gameserver/server_lib.zip -d $_dir/wg_libs"
  ssh root@${WANIP_CFG} "unzip -oq $_dir/wg_gameserver/wg_resource.zip -d $_dir/wg_resources"
  ssh root@${WANIP_CFG} "rm -rf /${_dir}/wg_gameserver"
  #db init
  echo_debug "Init sql for server "${SERVERNAME_CFG}"-"${DB_PORT_CFG}
  ssh root@${WANIP_CFG} "mysql -uroot -p123456 -h127.0.0.1 -P${DB_PORT_CFG} < /data${port2datax[${DB_PORT_CFG}]}/wg_db_init/lj_db_init.sql"
  ssh root@${WANIP_CFG} "mysql -uroot -p123456 -h127.0.0.1 -P${DB_PORT_CFG} < /data${port2datax[${DB_PORT_CFG}]}/wg_db_init/log_reason.sql"
  echo_debug "Init sql for server "${SERVERNAME_CFG}"-"${DB_PORT_CFG}" Finished! "
  echo_info "Begin deploy server Finished......."
}

install_depend_software() {
  ssh root@${WANIP_CFG} "rsync -av ${rsync_ip}::download/jdk7.tar.gz /data0/src/"
  ssh root@${WANIP_CFG} "tar -xzf /data0/src/jdk7.tar.gz -C /data0"
  ssh root@${WANIP_CFG} "yum install -y rsync"
  ssh root@${WANIP_CFG} "yum install -y libaio"
  ssh root@${WANIP_CFG} "yum install -y perl"
  ssh root@${WANIP_CFG} "yum install -y lrzsz"
}

install_mysql() {
  if ssh root@${WANIP_CFG} [ -d "/data0/mysql" ] || ssh root@${WANIP_CFG} [ -d "/var/lib/mysql3306" ]; then
    echo_err "HAVE MYSQL can not install a new one!!!"
    return
  fi
  if [ `ssh root@${WANIP_CFG} 'cat ~/.bashrc | grep mysql | wc -l'` -eq 0 ]; then
    echo 'export PATH=$PATH:/usr/local/mysql/bin/:/data0/jdk1.7.0_80/bin/' | ssh root@${WANIP_CFG} "cat >> ~/.bashrc"
  else
    echo_err "HAVE MYSQL config in the bashrc, myqsql is installed, sill install !!"
    return
  fi
  ssh root@${WANIP_CFG} "rsync -av ${rsync_ip}::download/Percona-Server-5.5.25a-rel27.1-277.Linux.x86_64.tar.gz /data0/src/"
  ssh root@${WANIP_CFG} "rsync -av ${rsync_ip}::download/my.cnf.multi_four.5.5 /data0/src/"
  ssh root@${WANIP_CFG} "cd /data0/src && tar -xzf Percona-Server-5.5.25a-rel27.1-277.Linux.x86_64.tar.gz -C /usr/local/"
  ssh root@${WANIP_CFG} "cd /usr/local && ln -s Percona-Server-5.5.25a-rel27.1-277.Linux.x86_64 mysql"

  ssh root@${WANIP_CFG} "useradd -M mysql -s /sbin/nologin"
  for _db_port in ${!port2datax[*]}
  do
    ssh root@${WANIP_CFG} "mkdir -p /data${port2datax[${_db_port}]}/mysql && chown mysql.mysql -R /data${port2datax[$_db_port]}/mysql"
    ssh root@${WANIP_CFG} "/bin/ln -s /data${port2datax[$_db_port]}/mysql /var/lib/mysql$_db_port && chown -R mysql.mysql /var/lib/mysql$_db_port"
    ssh root@${WANIP_CFG} "cd /usr/local/mysql/;./scripts/mysql_install_db --user=mysql --datadir=/var/lib/mysql${_db_port}"
  done
  #启动
  ssh root@${WANIP_CFG} "cp /data0/src/my.cnf.multi_four.5.5 /etc/my.cnf;cp /usr/local/mysql/support-files/mysqld_multi.server /etc/init.d/mysqld_multi.server"
  ssh root@${WANIP_CFG} '/etc/init.d/mysqld_multi.server start'
  echo_debug "Wait Mysql start...................wait..."
  sleep 25
  ssh root@${WANIP_CFG} '/etc/init.d/mysqld_multi.server report'
  #设置密码和用户
  for _db_port in ${!port2datax[*]}
  do
    ssh root@${WANIP_CFG} "mysql -uroot -h127.0.0.1 -P${_db_port} -e \"grant select on *.* to tongji@'119.29.252.93' identified by 'tongji1234!@#$';\""
    ssh root@${WANIP_CFG} "mysql -uroot -h127.0.0.1 -P${_db_port} -e \"grant all privileges on *.* to 'gmroot'@${LOCAL_CENTER_IP} identified by '12345600';\""
    ssh root@${WANIP_CFG} "mysql -uroot -h127.0.0.1 -P${_db_port} -e \"grant all privileges on *.* to 'root'@'127.0.0.1' identified by '123456';\""
    ssh root@${WANIP_CFG} "mysql -uroot -p123456 -h127.0.0.1 -P${_db_port} -e \"delete from mysql.user where password='';\""
    ssh root@${WANIP_CFG} "mysql -uroot -p123456 -h127.0.0.1 -p123456 -P${_db_port} -e \"flush privileges;\""
    echo_debug "sql grant finish at ${_db_port}"
  done
  #设置定时备份
  if ssh root@${WANIP_CFG} [ ! -f "/var/spool/cron/root" ] || [ `ssh root@${WANIP_CFG} "cat /var/spool/cron/root | grep backup_mysql | wc -l"` -eq 0 ]; then
    ssh root@${WANIP_CFG} 'echo "$(($RANDOM%60)) 04 * * * /usr/bin/python2  /data0/backup_mysql.py 2>&1 > /dev/null" >> /var/spool/cron/root'
  fi
  ssh root@${WANIP_CFG} "rsync -av ${rsync_ip}::download/backup_mysql.py /data0/"
}

test() {
  for _db_port in ${!port2datax[*]}
  do
    ssh root@${WANIP_CFG} "mysql -uroot -h127.0.0.1 -P${_db_port} -e \"grant select on *.* to tongji@'119.29.252.93' identified by 'tongji1234!@#$';\""
    ssh root@${WANIP_CFG} "mysql -uroot -h127.0.0.1 -P${_db_port} -e \"grant all privileges on *.* to 'gmroot'@${LOCAL_CENTER_IP} identified by '12345600';\""
    ssh root@${WANIP_CFG} "mysql -uroot -h127.0.0.1 -P${_db_port} -e \"grant all privileges on *.* to 'root'@'127.0.0.1' identified by '123456';\""
    ssh root@${WANIP_CFG} "mysql -uroot -p123456 -h127.0.0.1 -P${_db_port} -e \"delete from mysql.user where password='';\""
    ssh root@${WANIP_CFG} "mysql -uroot -p123456 -h127.0.0.1 -p123456 -P${_db_port} -e \"flush privileges;\""
    echo_debug "sql grant finish at ${_db_port}"
  done
}

read_config $1
generate_deploy_config
init_empty_cloud_service
install_depend_software
install_mysql
send_config_files
deploy_server
sleep 10

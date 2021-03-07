#! /usr/bin/bash
# -*-coding=utf8-*-
# @Auther: Yao Shuai
source ./echo_util.sh

GAME_ID=5614
LOCAL_CENTER_IP="119.29.197.61"

# 定义的数据库用户名和密码
declare -A db_password_config
DB_PASSWORD_CONFIG=([sys_user]=root [sys_password]=123456 \
                    [game_user]=root [game_password]=123456 \
                    [gm_user]=gmroot [gm_password]=12345600)

# 定义各种常亮，思路是约定大于配置
SERVER_PATH=(\\/data0 \\/data1 \\/data5 \\/data6)
MYSQL_PORT=(3306 3307 3308 3309)
GAME_PORT=(8080 8307 8308 8309)
TELNET_PORT=(7000 7307 7308 7309)
LOG_PORT=(8083 8007 8008 8009)
EX_PORT=(6060 6307 6308 6309)

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

#四个参数 比如s1 s2 s3 s4
server_file_names=($1 $2 $3 $4)
#-------------- 欢乐的常量定义完毕 ----------------------------
function generate_deploy_config() {
   server_file_names_arr=$1
   for i in ${server_file_names_arr[*]}; do
    echo "开始解析"$i"的配置脚本......."
    ## s1592.config格式：9655 1 s1592.qyz.feidou.com 10.10.6.195 119.29.150.151 s1592 true
    file_content=`cat /c/servers/$i.config`
    echo $file_content
    _serverId=`echo $file_content | awk '{print $1}'`
    _domain=`echo $file_content | awk '{print $3}'`
    _domain_prefix=`echo $_domain | awk 'BEGIN{FS="."} {print $1}'`
    _lanIp=`echo $file_content | awk '{print $4}'`
    _wanIp=`echo $file_content | awk '{print $5}'`
    _serverName=`echo $file_content | awk '{print $6}'`
    export SERVER_LAN_IP=$_lanIp
    export SERVER_WAN_IP=$_wanIp
    #------------------ 生成game server config .js文件 --------------
    echo "开始生成"$i"的server js配置脚本...="$_serverId $_domain $_domain_prefix $_lanIp $_wanIp $_serverName
    server_config_file=./generated/${_serverName}_game_sever.cfg.js
    cp ./template/game_sever.cfg.js.template $server_config_file
    #需要替换的字符串 #domain# #data_path# #mysql_port# #server_id# #server_name# #log_port# #game_port# #telnet_port#
    sed -i "s/#domain#/$domain/g" $server_config_file
    sed -i "s/#data_path#/${SERVER_PATH[$i]}/g" $server_config_file
    sed -i "s/#server_id#/$_serverId/g" $server_config_file
    sed -i "s/#server_name#/$_serverName/g" $server_config_file
    sed -i "s/#log_port#/${LOG_PORT[$i]}/g" $server_config_file
    sed -i "s/#game_port#/${GAME_PORT[$i]}/g" $server_config_file
    sed -i "s/#telnet_port#/${TELNET_PORT[$i]}/g" $server_config_file

    #------------------ 生成log server config .js文件 --------------
    echo "开始生成"$i"的log js配置脚本...="$_serverId $_domain $_lanIp $_wanIp $_serverName
    log_config_file=./generated/${_serverName}_log_server.cfg.js
    cp ./template/log_server.cfg.js.template $log_config_file
    #需要替换的字符串 #server_name# #wan_ip# #domain# #log_port# #lan_ip# #log_telnet_port#
    sed -i "s/#server_name#/$_serverName/g" $log_config_file
    sed -i "s/#wan_ip#/$_wanIp/g" $log_config_file
    sed -i "s/#domain#/$_serverName/g" $log_config_file
    sed -i "s/#log_port#/${LOG_PORT[$i]}/g" $log_config_file
    sed -i "s/#lan_ip#/$_lanIp/g" $log_config_file
    sed -i "s/#server_id#/$_serverId/g" $log_config_file

    #------------------ 生成game sever launch 脚本文件 --------------
    echo "开始生成"$i"的server启动脚本...="$_serverId $_domain $_lanIp $_wanIp $_serverName
    launch_server_file=./generated/${_serverName}_gameserver_launch.sh
    cp ./template/launch.sh.server.template $launch_server_file
    #需要替换的字符串 #server_name# #wan_ip# #domain# #log_port# #lan_ip# #log_telnet_port#
    sed -i "s/#server_name#/$_serverName/g" $launch_server_file
    sed -i "s/#wan_ip#/$_wanIp/g" $launch_server_file
    sed -i "s/#log_port#/${LOG_PORT[$i]}/g" $launch_server_file
    sed -i "s/#lan_ip#/$_lanIp/g" $launch_server_file
    sed -i "s/#server_id#/$_serverId/g" $launch_server_file

    #------------------ 生成log sever launch 脚本文件 --------------
    echo "开始生成"$i"的log启动脚本...="$_serverId $_domain $_lanIp $_wanIp $_serverName
    launch_log_file=./generated/${_serverName}_logserver_launch.sh
    cp ./template/launch.sh.log.template $launch_log_file
    #需要替换的字符串 #server_name# #wan_ip# #domain# #log_port# #lan_ip# #log_telnet_port#
    sed -i "s/#server_name#/$_serverName/g" $launch_log_file
    sed -i "s/#server_id#/$_serverId/g" $launch_log_file

    #------------------ 生成 gmserver的 db1下xml文件 --------------
    echo "开始生成"$i"的gm配置xml...="$_serverId $_domain $_lanIp $_wanIp $_serverName
    gm_xml_file=./generated/${_serverName}_db.xml
    cp ./template/gm_db.xml.template $gm_xml_file
     #需要替换的字符串 #server_name# #wan_ip# #domain# #log_port# #lan_ip# #log_telnet_port#
    sed -i "s/#server_name#/$_serverName/g" $gm_xml_file
    sed -i "s/#wan_ip#/$_wanIp/g" $gm_xml_file
    sed -i "s/#domain#/$_domain/g" $gm_xml_file
    sed -i "s/#log_port#/${LOG_PORT[$i]}/g" $gm_xml_file
    sed -i "s/#lan_ip#/$_lanIp/g" $gm_xml_file
    sed -i "s/#server_id#/$_serverId/g" $gm_xml_file
    sed -i "s/#mysql_port#/${MYSQL_PORT[$i]}/g" $gm_xml_file
  done
}

init_empty_cloud_service() {
  echo_err ${SERVER_WAN_IP}
  if ssh root@${SERVER_WAN_IP} [ -d "/data0" ] || ssh root@${SERVER_WAN_IP} [ -d "/var/lib/mysql" ]; then
    echo_err "当前云服不是未初始化的不能执行该脚本！"
    exit 1;
  else
    echo_info "开始进行初始化云服操作........"
  fi

  mount_data0=`ssh root@${SERVER_WAN_IP} mount | grep data0 |wc -l`
  if [ $mount_data0 -ne 0 ]; then
    echo_err "当前云服可能已经挂载数据盘不能执行该脚本！"
    exit 1;
  fi

  disk_count=`ssh root@${SERVER_WAN_IP} fdisk -l | grep /dev/vdb | wc -l`
  if [ $disk_count -eq 0 ];then
    echo "没有数据盘，不需要挂载硬盘，省事儿了~~~~"
    return 0
  fi
  ssh root@${SERVER_WAN_IP} echo "n
  p
  1


  w
  " | fdisk /dev/vdb && mkfs -t ext4 /dev/vdb1 && mkdir /data0 && mount /dev/vdb1 /data0
  ssh root@${SERVER_WAN_IP} df -TH

}


send_to_server() {
  echo 1
}

generate_deploy_config "${server_file_names[*]}"
#初始化目标服务器 0.安装依赖，挂载数据盘设置swap 1.目录结构 2.jdk 3.mysql
init_empty_cloud_service
#把配置放到对应的目录结构
#生成目标服务器的目录结构
#把生成的东西拷贝过去 如果不是新服的话不能拷贝
##send_to_server "${server_file_names[*]}"
#

sleep 10000

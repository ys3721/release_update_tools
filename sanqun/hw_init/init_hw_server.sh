#! /usr/bin/bash
# -*-coding=utf8-*-
# @Auther: Yao Shuai

GAME_ID=5614
LOCAL_CENTER_IP="119.29.197.61"

# 定义的数据库用户名和密码
declare -A db_password_config
db_password_config=([sys_user]=root [sys_password]=123456 \
                    [game_user]=root [game_password]=123456 \
                    [gm_user]=gmroot [gm_password]=12345600)

# 定义java堆内存大小
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



sleep 1000

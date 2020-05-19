#!/bin/bash
#Author yaoshui @Date 2020-05-19
read -p "input the ss1 password of root:" password
#这里的ls是执行一个命令 要不然ssh默认的操作是登录上去
sshpass -p $password ssh root@49.51.36.190 -o StrictHostKeyChecking=no echo 'connect ok'
sshpass -p $password ssh root@49.51.36.190 "rm -f /data0/wg_release_branch*.zip&&rm -f /data1/wg_release_branch*.zip&&rm -f /data5/wg_release_branch*.zip&&rm -f /data6/wg_release_branch*.zip"
echo rm ok

sshpass -p $password scp /data0/wg_ftp/server_release/zh_CN/package/1.21.0.0/wg_release_branch*.zip root@49.51.36.190:/data0/
sshpass -p $password ssh root@49.51.36.190 "cp /data0/wg_release_branch*.zip /data1/&&cp /data0/wg_release_branch*.zip /data5/&&cp /data0/wg_release_branch*.zip /data5/&&cd /data0&&sh update_locate_server.sh -ua"

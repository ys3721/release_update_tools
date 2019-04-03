#!/bin/bash
dir=`pwd | awk -F '/' '{print "/"$2}'`
if [[ $dir =~ "/data" ]]; then
    echo "begin deploy $dir"
else
    exit -1
fi
echo work dir is $dir !!!
sleep 2
#删除老文件
echo Removing old files...
rm -rf $dir/wg_logs
rm -rf $dir/wg_db
rm -rf $dir/wg_libs
rm -rf $dir/wg_resources
rm -rf $dir/wg_deploy/deploy_tool*.*
rm -rf $dir/wg_deploy/*/
rm -rf $dir/wg_config
rm -rf $dir/wg_script

#执行命令解压缩wg_release_*.*.*.*.zip
unzip -o $dir/wg_release_*.zip -d $dir
echo 'unzip all wg_release zip ok'

#将$dir/server/resource.zip解压缩到$dir/resource目录下
mkdir -p $dir/wg_resources
unzip -oq $dir/wg_gameserver/wg_resource.zip -d $dir/wg_resources
echo 'unzip all wg_resources zip ok'

#将$dir/wg_gameserver/server_lib.zip解压缩到$dir/wg_libs目录下
mkdir -p $dir/wg_libs
unzip -oq $dir/wg_gameserver/server_lib.zip -d $dir/wg_libs
echo 'unzip all wg_libs zip ok'

#运行发布工具
cd $dir/wg_deploy
unzip -o deploy_tools.zip
sh run_deploytool.sh
echo 'run deploy tool finish , and copy config to wg_config finish !!'

#清除临时文件
echo Removing temp files...
rm -rf $dir/wg_gameserver


mkdir $dir/wg_script
#拷贝启动game_server
cd $dir
cp $dir/wg_config/game_server_config/launch.sh $dir/wg_script/gameserver_launch.sh
chmod +x $dir/wg_script/gameserver_launch.sh
echo copy wg_gameserver finish...

#拷贝启动log_server
cp $dir/wg_config/log_server_config/launch.sh $dir/wg_script/logserver_launch.sh
chmod +x $dir/wg_script/logserver_launch.sh
echo copy launch for wg_logs finish...

echo Deploy completed!
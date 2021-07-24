#!/usr/bin bash
<<!
 **********************************************************
 * Author        : Yao Shuai
 * 本地启动一些依赖的. 数据库  redis
 * *******************************************************
!
proj="ascension"
src="./"
dest="../build"
env="test"
rm -rf $dest
cd $src
#git checkout .
#git pull
mkdir $dest $dest/config  $dest/assets
GOOS=linux GOARCH=amd64 go build -o $dest/$proj ./main/main.go
#go build -o $dest/$proj ./main/main.go
##拷贝表数据
cp -r ./config/jsondata $dest/config/
##拷贝配置数据yml $WORK_SPACE/assets/
cp -r ./assets/$env $dest/assets/
cur_dateTime="`date +%Y-%m-%d,%H:%m:%s`"
cd $dest && tar -czvf asscension_$cur_dateTime.tar.gz ./*
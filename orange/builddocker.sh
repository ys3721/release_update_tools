#!/usr/bin bash

server_path='/data2/repo_share/ascension-server/'

cd $server_path
git pull

cd $server_path/server/
sh ./build.sh release

cd $server_path/build/
package_name=`ls ascension_release_*.tar.gz`
if [[ $package_name == "" ]];then
    echo "打包失败，没有找到需要的发布包！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1"
    return -1
fi
\cp $package_name /data/packages/release/

cd /data/packages/release/
rm -f /data/ascension-release/ascension_*.tar.gz
\cp $package_name /data/ascension-release/
cd /data/ascension-release/
sh ./untar.sh

cd /data/ascension-k8s/
./build.sh
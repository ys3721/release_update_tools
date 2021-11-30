
#!/usr/bin bash
#author        : Yao Shuai 人生总是需要一点痕迹的
##Create time   : 2021-07-28 14:01

makedata_workspace="/data2/repo_share/dev-version/"
makedata_dir="/data2/repo_share/dev-version/cultivation_makedata/"
server_dir="/data2/repo_share/dev-version/ascension-server/"
msg="no"

function pull_hard() {
  cd $1
  git pull
}

function gen_go_config() {
  cd $makedata_workspace
  hortor-cli config ${makedata_dir}/config-go.js
  cd $makedata_dir
  version=`git rev-parse --short HEAD`
  echo "$version" >./out/go/config/data_version
  msg=`git show |xargs| awk -F- '{print $1}'`
}

function cp_config_and_push() {
  echo "Begin copy the config.go and config json in $makedata_dir to $server_dir"
  \cp -rf ${makedata_dir}/out/go/config.go $server_dir/server/config/config.go
  \cp -rf ${makedata_dir}/out/go/config/* $server_dir/server/config/jsondata/
}

function push_server_master() {
    cd $server_dir
    git add ./
    git commit -m"[dev页面]提交了表$msg"
    git push -u origin dev
}

pull_hard $makedata_dir
pull_hard $server_dir
gen_go_config
cp_config_and_push
push_server_master
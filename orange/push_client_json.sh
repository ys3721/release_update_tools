#!/usr/bin bash

makedata_workspace="/data2/repo_share/cultivation_client/"
makedata_dir="/data2/repo_share/cultivation_makedata/"
client_dir="/data2/repo_share/cultivation_client/"
msg="no"

function pull_hard() {
  cd $1
  #git fetch --all
  #git reset --hard master
  git pull
}

function gen_js_config() {
  cd $makedata_workspace
  npm run makeData
  cd $makedata_dir
  msg=`git show |xargs| awk -F- '{print $1}'`
}

function push_client_master() {
    cd $client_dir
    git add ./
    git commit -m"[页面]提交了数据表$msg"
    git push -u origin master
}

pull_hard $makedata_dir
pull_hard $client_dir
gen_js_config
push_client_master
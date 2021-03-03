#! /usr/bin/bash
# -*-coding=utf8-*-
# @Auther: Yao Shuai

check_empty(){
  if [ -d "/data0" ]; then
    echo "当前云服不是未初始化的不能执行该脚本！"
    exit 1;
  fi

  mount_data0=`mount | grep data0 |wc -l`
  if [ $mount_data0 -ne 0 ]; then
    echo "当前云服可能已经挂载数据盘不能执行该脚本！"
    exit 1;
  fi
}

#挂载数据盘，空行不要删除，里面回车要的给fdisk命令使用
mount_data_disk() {
  echo "开始初始化挂载数据盘..."
  echo "n
  p
  1


  w
  " | fdisk /dev/vdb1 && mkfs -t ext4 /dev/vdb1 && mkdir /data0 && mount /dev/vdb1 /data0
  df -TH
}


check_empty
mount_data_disk
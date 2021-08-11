#!/usr/bin bash
<<!
 **********************************************************
 * Author        : Yao Shuai
 * 本地启动一些依赖的. 数据库  redis
 * *******************************************************
!
#echo 'hortor' | sudo nohup mongod --dbpath ~/data0/mongodb 1>&2 1>/dev/null &
#echo 'hortor' | sudo redis-server /etc/redis/redis.conf

## home mac
mongod --config /usr/local/etc/mongod.conf
redis-server /etc/redis6379.conf

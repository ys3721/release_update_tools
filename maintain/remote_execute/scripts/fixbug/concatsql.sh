#!/usr/bin/env bash
#cut -f1 ./fix_subscribe_time.sh
#clear
awk 'BEGIN { i=0 } { i++ } END { print i }' ./fix_subscribe_time.sh
#ps -elf | awk '{ print $1 }'

awk '{ print "update t_platform_user set subexpiretime ="$2" where id = (select distinct passportId from t_orders where roleId ="$1"); "}' ./fix_subscribe_time.sh

sleep 20
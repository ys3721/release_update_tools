#!/bin/sh
ip="$1"
ssh $ip "export PATH=$PATH:/usr/local/mysql/bin/;sh /etc/init.d/mysqld_multi.server start";

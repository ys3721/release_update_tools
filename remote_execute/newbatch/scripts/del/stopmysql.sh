#!/bin/sh
ip="$1"
ssh $ip "/usr/local/mysql/bin/mysqladmin -uroot -p123456 -P3306 -h127.0.0.1 -S /var/lib/mysql/mysql.sock shutdown";
ssh $ip "/usr/local/mysql/bin/mysqladmin -uroot -p123456 -P3307 -h127.0.0.1 -S /var/lib/mysql3307/mysql.sock shutdown";
ssh $ip "/usr/local/mysql/bin/mysqladmin -uroot -p123456 -P3308 -h127.0.0.1 -S /var/lib/mysql3308/mysql.sock shutdown";
ssh $ip "/usr/local/mysql/bin/mysqladmin -uroot -p123456 -P3309 -h127.0.0.1 -S /var/lib/mysql3309/mysql.sock shutdown";

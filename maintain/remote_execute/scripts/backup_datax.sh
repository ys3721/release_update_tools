#!/usr/bin bash

backup()
{
    if [ -d "/data1" ]; then
        tar -czvf /data0/sql_back/data1.tar.gz /data1
    fi

    if [ -d "/data5" ]; then
        tar -czvf /data0/sql_back/data5.tar.gz /data5
    fi

    if [ -d "/data6" ]; then
        tar -czvf /data0/sql_back/data6.tar.gz /data6
    fi
}

stop_mysql()
{
    ps -elf | grep mysqld | grep -v grep | awk '{print $4}' | xargs kill
    sleep 20
    count=`ps -elf | grep mysqld | grep -v grep | wc l`
    if [ $count -gt 0 ]; then
        echo 'mysql not dead!!'
        exit 1
    fi
}

move_data_dir()
{
    if [ -d "/data1" ]; then
        mv /data1/mysql /data0/mysql3307
        rm -f /var/mysql3307
        ln -s /data0/mysql3307 /var/mysql3307
    fi

    if [ -d "/data5" ]; then
        mv /data5/mysql /data0/mysql3308
        rm -f /var/mysql3308
        ln -s /data0/mysql3308 /var/mysql3308
    fi

    if [ -d "/data6" ]; then
        mv /data6/mysql /data0/mysql3309
        rm -f /var/mysql3309
        ln -s /data0/mysql3309 /var/mysql3309
    fi
}

start_mysql()
{
    /etc/init.d/mysqld_multi.server start
}

main(){
    `backup`
    `stop_mysql`
    `move_data_dir`
    `start_mysql`
}



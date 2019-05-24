#!/usr/bin bash

backup()
{
    cd /data0
    echo "start back up tar data！"
    if [ -d "/data1" ]; then
        tar -czPf data1.tar.gz /data1
    fi

    if [ -d "/data5" ]; then
        tar -czPf data5.tar.gz /data5
    fi

    if [ -d "/data6" ]; then
        tar -czPf data6.tar.gz /data6
    fi
}

stop_mysql()
{
    export PATH=/usr/local/mysql/bin:$PATH
    ps -elf | grep mysqld | grep -v grep | awk '{print $4}' | xargs kill
    sleep 220
    count=`ps -elf | grep mysqld | grep -v grep | wc -l`
    echo "stop mysql finished!!"$count
    echo `/etc/init.d/mysqld_multi.server report`
    echo \n
}

move_data_dir()
{
    if [ -d "/data1" ]; then
        mv /data1/mysql /data0/mysql3307
        rm -f /var/lib/mysql3307
        ln -s /data0/mysql3307 /var/lib/mysql3307
    fi

    if [ -d "/data5" ]; then
        mv /data5/mysql /data0/mysql3308
        rm -f /var/lib/mysql3308
        ln -s /data0/mysql3308 /var/lib/mysql3308
    fi

    if [ -d "/data6" ]; then
        mv /data6/mysql /data0/mysql3309
        rm -f /var/lib/mysql3309
        ln -s /data0/mysql3309 /var/lib/mysql3309
    fi
     echo "move mysql data folder finished！"
}

start_mysql()
{
    export PATH=/usr/local/mysql/bin:$PATH
    /etc/init.d/mysqld_multi.server start
    sleep 25
    echo `/etc/init.d/mysqld_multi.server report`
}

check()
{
    if [ ! -d /data1/mysql ]; then
        echo "not need move mysql data！"
        exit 1
    fi
}

main(){
    check
    stop_mysql
    backup
    move_data_dir
    start_mysql
}

main

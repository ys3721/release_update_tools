#!/bin/sh

export PATH="/usr/lib64/qt-3.3/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/sbin:/usr/sbin:/usr/local/sbin:/root/bin"

# script dir
SCRIPTDIR="/data0/zeus/sadir/tools"
DBDIR="/var/lib/mysql/wg_lj_log"
DB_TABLE_FLAG="chat*.frm"
VALUE="85"
# log save day
NO_DEL_TIME=`date -d '45 day ago' +%Y_%m_%d`
# script log save dir
LOG_FILE="${SCRIPTDIR}/clean_game_log.log"

# save clean log
write_log(){
  now_time='['$(date +"%Y-%m-%d %H:%M:%S")']'
  echo ${now_time} $1 | tee -a ${LOG_FILE}

}

# getDeletetime
getDeletetime()
{
	cd $DBDIR
	deletetime=`ls ${DB_TABLE_FLAG}|sort|head -n 1|awk -F'[_|.]' '{print $3"_"$4"_"$5}'`
	echo $deletetime
}

# genDroptable
genDroptable()
{
	cd $DBDIR
	oldtime=`getDeletetime`
	tables=`ls *.frm|grep "$oldtime"|awk -F. '{print $1}'|grep -v gold_money_log`
	cd $SCRIPTDIR
	echo "use wg_lj_log;">clean_game_log.sql
	for i in $tables
	do
		echo "drop table "$i";">>clean_game_log.sql
	done
}

cleanGamelog()
{
	genDroptable
	cd $SCRIPTDIR
	if [ -x '/usr/local/mysql/bin/mysql' ]
	then
                cat $SCRIPTDIR/clean_game_log.sql >>${LOG_FILE}
		/usr/local/mysql/bin/mysql -uroot -p123456 -h127.0.0.1  -P3307< $SCRIPTDIR/clean_game_log.sql;
	else
                cat $SCRIPTDIR/clean_game_log.sql >>${LOG_FILE}
		mysql -uroot -p123456 -h127.0.0.1 -P3307 < $SCRIPTDIR/clean_game_log.sql;
	fi
}

# check disk
disk_space(){
/bin/df |grep data0 >/dev/null 2>&1
if [ ! $? -eq 0 ]
then
    DISK_SIZE=`/bin/df -TH|awk -F [%] '/\/$/{print $1}'|awk '{print $NF}'`
else
    DISK_SIZE=`/bin/df -TH|awk -F [%] '/data0/{print $1}'|awk '{print $NF}'`
fi
echo $DISK_SIZE

}

# clean binlog
cleanBinlog(){
	if [ -x '/usr/local/mysql/bin/mysql' ]
	then
		/usr/local/mysql/bin/mysql --default-character-set=utf8 -h127.0.0.1 -u root -p123456 -P3307 -e "show master status" > /root/master_binlog
		binlog_pos=`grep mysql-bin /root/master_binlog | awk '{print $1'}`
		echo $binlog_pos
		/usr/local/mysql/bin/mysql -h127.0.0.1 --default-character-set=utf8 -u root -p123456 -P3307 -e "purge binary logs to '$binlog_pos'"
	else
		mysql --default-character-set=utf8 -h127.0.0.1 -u root -p123456 -e -P3307 "show master status" > /root/master_binlog
		binlog_pos=`grep mysql-bin /root/master_binlog | awk '{print $1'}`
		echo $binlog_pos
		mysql -h127.0.0.1 --default-character-set=utf8 -u root -p123456 -e -P3307 "purge binary logs to '$binlog_pos'"
	fi
}

# clean sql_bak
clean_Sqlbak(){
	if [ -d '/data0/sql_bak' ]
	then
		write_log "start clean /data0/sql_bak"
		find /data0/sql_bak -type f -name "*.sql" -ctime +30 -exec rm -f {} \;
	else
		write_log "dir /data0/sql_bak is not exist!!!"
	fi
}
# main function
main()
{
	flag=`getDeletetime`
	while [ `disk_space` -gt $VALUE ]
	do
		if [[ "$flag" < "$NO_DEL_TIME" ]]
		then
			clean_Sqlbak
			write_log "start drop tables $flag"
			cleanGamelog
		else
			write_log "$flag > $NO_DEL_TIME not drop,exit"
			write_log "start clean mysql binlog"
			cleanBinlog
		fi
	done
}

main

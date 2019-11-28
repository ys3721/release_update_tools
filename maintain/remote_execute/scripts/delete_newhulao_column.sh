#!/usr/bin/env bash
if [ -d /var/lib/mysql ]; then
    echo '/usr/local/mysql/bin/mysql -uroot -p123456 -h127.0.0.1 wg_lj -e "alter table t_sys_info drop column newHulaoRankInfo";'
    /usr/local/mysql/bin/mysql -uroot -p123456 -h127.0.0.1 wg_lj -e "alter table t_sys_info drop column newHulaoRankInfo";
fi

if [ -d /var/lib/mysql3307 ]; then
    echo '/usr/local/mysql/bin/mysql -uroot -p123456 -h127.0.0.1 -P3307 wg_lj -e "alter table t_sys_info drop column newHulaoRankInfo";'
    /usr/local/mysql/bin/mysql -uroot -p123456 -h127.0.0.1 -P3307 wg_lj -e "alter table t_sys_info drop column newHulaoRankInfo";
fi
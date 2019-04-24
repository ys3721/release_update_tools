#! /usr/bin/python
# -*-coding=utf8-*-
# @Auther: Yao Shuai

"""
支持新安装2个或者4个mysql的实例，如果是2个实例的话，innodb pool size 是每个2G，
如果安装4个instance的话，那么只有每个pool size 只有 1G， 暂时足够现有游戏阶段的人数要求
data0 data1 data5 data6 下面是mysql的数据目录
比之前不同的是直接创建mysql账号 不要等到instal server中跑了
"""
import os
import time
import sys
import random

class MysqlInstaller(object):

    def __init__(self, instance_count, user="root", password="123456", game_user='', game_password="",
                 gm_lang_ip="10.10.2.3", gm_user="gmroot", gm_password="12345600",
                 local_ip1="119.29.252.93", local_ip2="10.10.2.105", local_user="tongji", local_password="tongji1234!@#$"):
        self.instance_count = instance_count
        self.lan_ip = '127.0.0.1'
        self.user = user
        self.password = password

        self.gm_lan_ip = gm_lang_ip
        self.gm_user = gm_user
        self.gm_password = gm_password

        self.local_ip1 = local_ip1
        self.local_ip2 = local_ip2
        self.local_user = local_user
        self.local_password = local_password

        self.game_user = game_user
        self.game_password= game_password

        self.grant_all_info = [(self.gm_user, self.gm_lan_ip, self.gm_password),
                               (self.game_user, self.lan_ip, self.game_password),
                               (self.user, self.lan_ip, self.password)]
        self.grant_select_info = [(self.local_user, self.local_ip1, self.local_password),
                                  (self.local_user, self.local_ip2, self.local_password)]
        pass

    def check(self):
        if self.instance_count != 1 and self.instance_count != 2 and self.instance_count != 4:
            print "1 2 4 is ok,  other is not ok!! count=%d" % self.instance_count
            return False
        if os.path.exists("/data0/mysql") or os.path.exists("/data1/mysql3307") \
                or os.path.exists("/data5/mysql3308") or os.path.exists("/data6/mysql3309"):
            return False
        if os.path.exists("/var/lib/mysql") or os.path.exists("/var/lib/mysql3307") \
                or os.path.exists("/var/lib/mysql3308") or os.path.exists("/var/lib/mysql3309"):
            return False
        return True

    def prepare(self):
        print '[install mysql] base soft rsync begin!'
        os.system('yum install rsync -y')
        print '[install mysql] base soft rsync ok!'

        print '[install mysql] rsync remote Percona mysql to data0 src!'
        if not os.path.exists('/data0/src'):
            os.makedirs('/data0/src')
        os.system("cd /data0/src && rsync -avP 10.10.2.4::download/base/Percona-Server-5.5.25a-rel27.1-277.Linux.x86_64.tar.gz  /data0/src")
        print '[install mysql] rsync remote Percona mysql to data0 ok!'

        passwd_file = open('/etc/passwd', 'r')
        if 'mysql' not in passwd_file.read():
            os.system('useradd -M mysql -s /sbin/nologin')

    def config(self):
        os.system('cd /data0/src && tar -xzf Percona-Server-5.5.25a-rel27.1-277.Linux.x86_64.tar.gz -C /usr/local/')
        os.system('cd /usr/local && ln -s Percona-Server-5.5.25a-rel27.1-277.Linux.x86_64 mysql')

    def install(self):
        data_dir_one = '/data0/mysql'
        soft_line_data_dir_one = '/var/lib/mysql'
        os.mkdir(data_dir_one)
        os.system('/bin/chown mysql.mysql -R %s' % data_dir_one)
        os.system('/bin/ln -s %s %s && chown -R mysql.mysql %s' % (data_dir_one, soft_line_data_dir_one, soft_line_data_dir_one))

        if self.instance_count >= 2:
            data_dir_two = '/data1/mysql'
            soft_line_data_dir_two = '/var/lib/mysql3307'
            os.mkdir(data_dir_two)
            os.system('/bin/chown mysql.mysql -R %s' % data_dir_two)
            os.system('/bin/ln -s %s %s && chown -R mysql.mysql %s' % (data_dir_two, soft_line_data_dir_two, soft_line_data_dir_two))

        if self.instance_count >= 4:
            data_dir_three = '/data5/mysql'
            soft_line_data_dir_three = '/var/lib/mysql3308'
            os.mkdir(data_dir_three)
            os.system('/bin/chown mysql.mysql -R %s' % data_dir_three)
            os.system('/bin/ln -s %s %s && chown -R mysql.mysql %s' % (data_dir_three, soft_line_data_dir_three, soft_line_data_dir_three))

            data_dir_four = '/data6/mysql'
            soft_line_data_dir_four = '/var/lib/mysql3309'
            os.mkdir(data_dir_four)
            os.system('/bin/chown mysql.mysql -R %s' % data_dir_four)
            os.system('/bin/ln -s %s %s && chown -R mysql.mysql %s' % (data_dir_four, soft_line_data_dir_four, soft_line_data_dir_four))

        # 用哪个启动脚本
        if self.instance_count == 1:
            os.system('cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql_3306')
        else:
            os.system('cp /usr/local/mysql/support-files/mysqld_multi.server /etc/init.d/mysqld_multi.server')

        print 'begin install mysql 3306!'
        os.system('cd /usr/local/mysql/;./scripts/mysql_install_db --user=mysql --datadir=%s' % soft_line_data_dir_one)
        if self.instance_count >= 2:
            os.system('cd /usr/local/mysql/;./scripts/mysql_install_db --user=mysql --datadir=%s' % soft_line_data_dir_two)
        if self.instance_count >= 4:
            os.system('cd /usr/local/mysql/;./scripts/mysql_install_db --user=mysql --datadir=%s' % soft_line_data_dir_three)
            os.system('cd /usr/local/mysql/;./scripts/mysql_install_db --user=mysql --datadir=%s' % soft_line_data_dir_four)

        if os.path.exists('/etc/my.cnf'):
            os.system('mv /etc/my.cnf /etc/my.cnf.default.bak')

        if self.instance_count == 1:
            os.system('rsync -avP 10.10.2.4::download/base/my.cnf.5.5 /etc/')
            os.system('mv /etc/my.cnf.5.5 /etc/my.cnf')
        elif self.instance_count == 2:
            os.system('rsync -avP 10.10.2.4::download/base/my.cnf.multi_two.5.5 /etc/')
            os.system('mv /etc/my.cnf.multi_two.5.5 /etc/my.cnf')
        else:
            os.system('rsync -avP 10.10.2.4::download/base/my.cnf.multi_four.5.5 /etc/')
            os.system('mv /etc/my.cnf.multi_four.5.5 /etc/my.cnf')

        print '[install mysql] install mysql finish !!!'

    def grant(self) :
        if self.instance_count == 1:
            end_port = 3307
        elif self.instance_count == 2:
            end_port = 3308
        else:
            end_port = 3310

        for port in range(3306, end_port):
            for select_info in self.grant_select_info:
                select_info_with_port = (port,) + select_info
                print "/usr/local/mysql/bin/mysql -uroot -h127.0.0.1 -P%d -e \"grant select on *.* to '%s'@'%s' identified by '%s';\"" % select_info_with_port
                os.system("/usr/local/mysql/bin/mysql -uroot -h127.0.0.1 -P%d -e \"grant select on *.* to '%s'@'%s' identified by '%s';\"" % select_info_with_port)
                time.sleep(1)
            for insert_info in self.grant_all_info:
                if insert_info[0] != "":
                    insert_info_with_port = (port,) + insert_info
                    print "/usr/local/mysql/bin/mysql -uroot -h127.0.0.1 -P%d -e \"grant all privileges on *.* to '%s'@'%s' identified by '%s';\"" % insert_info_with_port
                    os.system("/usr/local/mysql/bin/mysql -uroot -h127.0.0.1 -P%d -e \"grant all privileges on *.* to '%s'@'%s' identified by '%s';\"" % insert_info_with_port)
                    time.sleep(1)
            # 清除空用户
            os.system("/usr/local/mysql/bin/mysql -uroot -p%s -h127.0.0.1 -P%d -e \"delete from mysql.user where password='';\"" % (self.password, port))
            os.system("/usr/local/mysql/bin/mysql -uroot -p%s -h127.0.0.1 -P%d -e \"flush privileges;\"" % (self.password, port))
            print 'Grant all privileges finished! test it, port=%d!' % port
            time.sleep(1)


    def start_mysql(self):
        if self.instance_count == 1:
            os.system('/etc/init.d/mysql_3306 start')
            time.sleep(5)
        else:
            os.system('export PATH=/usr/local/mysql/bin:$PATH && /etc/init.d/mysqld_multi.server start')
            time.sleep(30)
            os.system('export PATH=/usr/local/mysql/bin:$PATH && /etc/init.d/mysqld_multi.server report')

    def cron_back_up(self):
        role_cron_file = open("/var/spool/cron/root", "r")
        content = role_cron_file.read()
        if "backup_mysql.py" not in content:
            rand = random.randint(1,60)
            os.system('echo "%d 04 * * * /usr/bin/python  /data0/backup_mysql.py 2>&1 > /dev/null" >> /var/spool/cron/root' % rand)

    def check_and_install(self):
        if self.check():
            self.prepare()
            self.config()
            self.install()
            self.start_mysql()
            self.grant()
            self.cron_back_up()
        else:
            print 'Install Mysql check Fail !'


args = sys.argv
instance_count = int(args[1])
root_password = args[2]
gm_ip = args[3]
gm_password = args[4]
game_user = args[5]
game_password = args[6]

installer = MysqlInstaller(instance_count, password=root_password, game_user=game_user, game_password=game_password, gm_lang_ip=gm_ip, gm_password=gm_password)
installer.check_and_install()

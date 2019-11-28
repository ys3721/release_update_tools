#! /usr/bin/python
# -*-coding=utf8-*-
# @Auther: Yao Shuai

import commands, os
from sys import argv
import re
import platform

script_name, in_or_out = argv

def execute_linux_command(cmd):
    try:
        x,y = commands.getstatusoutput(cmd)
        if x != 0:
            print "cmd %r execute error!" % cmd
            print x,y,cmd
        return x,y
    except:
        print 'Execute exception>\n'


def execute_windows_command(cmd):
    print "Will execute windows cmd %s" % cmd
    p = os.popen(cmd)
    print p.readlines()


char_table = ['t_character']
char_id_table = ['t_quest', 't_character_bonus', 't_character_offline', 't_character_static', 't_guild_member']
char_ref_table = ['t_hero', 't_item', 't_mail', 't_pet']

for char_id_table_name in char_id_table:
    print char_id_table_name

if in_or_out == 'out':
    char_id = raw_input("input will export charId> \n")
    for char_table_name in char_table:
        print '/usr/local/mysql/bin/mysqldump --skip-add-drop-table --no-create-info -uroot -p -h127.0.0.1 wg_lj %s -wid=%s > /data0/backup/%s_character.sql' % (char_table_name, char_id, char_id)
        execute_linux_command('/usr/local/mysql/bin/mysqldump --skip-add-drop-table --no-create-info -uroot -p123456 -h127.0.0.1 wg_lj %s -wid=%s > /data0/backup/%s_character.sql' % (char_table_name, char_id, char_id))
    for char_id_table_name in char_id_table:
        print '/usr/local/mysql/bin/mysqldump --skip-add-drop-table --no-create-info -uroot -p -h127.0.0.1 wg_lj %s -wid=%s >> /data0/backup/%s_character.sql' % (char_id_table_name, char_id, char_id)
        execute_linux_command('/usr/local/mysql/bin/mysqldump --skip-add-drop-table --no-create-info -uroot -p123456 -h127.0.0.1 wg_lj %s -wid=%s >> /data0/backup/%s_character.sql' % (char_id_table_name, char_id, char_id))
    for char_ref_table_name in char_ref_table:
        print '/usr/local/mysql/bin/mysqldump --skip-add-drop-table --no-create-info -uroot -p -h127.0.0.1 wg_lj %s -wcharId=%s >> /data0/backup/%s_character.sql' % (char_ref_table_name, char_id, char_id)
        execute_linux_command('/usr/local/mysql/bin/mysqldump --skip-add-drop-table --no-create-info -uroot -p123456 -h127.0.0.1 wg_lj %s -wcharId=%s >> /data0/backup/%s_character.sql' % (char_ref_table_name, char_id, char_id))

if in_or_out == 'in':
    if 'Windows' not in platform.system():
        exit(-1)
    sql_file_path = raw_input("Where is the sql dump file path you want import? DANGEROUS!!!> \r\n")
    regular_express = r'\d+'
    regular_compiled = re.compile(regular_express)
    finds = regular_compiled.findall(sql_file_path)
    char_id = finds[0]
    execute_windows_command('mysql -uroot -p123456 -h127.0.0.1 wg_lj < %s' % sql_file_path)
    print "I think the %s is import to the db!!"
    execute_windows_command('mysql -uroot -p123456 -h127.0.0.1 wg_lj -e"update t_character set passportId = 999 where id = %s "' % char_id)
    print "I think import is finished!"

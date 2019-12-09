#! /usr/bin/python
#  -*-encoding=utf8-*-
# @Auther: Yao Shuai
import os, re

def fill_mysql_by_order():
    """把data0下的 s933_20191120100422_3306.sql 灌到数据库中，其中3306等等不是按照文件名的顺序
    而是按照 服务器名称前锥齿鼠的顺序来的"""
    prog = re.compile(r"""[a-z0-9_]*_330[6-9].sql$""")
    sql_files = []
    for folder_name, subfolders, file_names in os.walk("/data0/src/"):
        for file_name in file_names:
            if prog.match(file_name):
                sql_files.append(file_name)
    sql_files.sort(lambda s1, s2: cmp(s1, s2))
    for i in range(3306, 3306 + len(sql_files), 1):
        fill_cmd = "/usr/local/mysql/bin/mysql -uroot -p1234xxx56 -h127.0.0.1 -P%d wg_lj < %s" % (i, sql_files[i-3306])
        print fill_cmd
        #os.system(fill_cmd)

fill_mysql_by_order()
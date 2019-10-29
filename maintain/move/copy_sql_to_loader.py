#! /usr/bin/python
# -*-coding=utf8-*-
# @Auther: Yao Shuai

# 文件名的格式形如 20191029151747_3306.sql 一定带一个_3306和一个日期时间的前缀
import os, shutil, sys, getopt
import re

argv = sys.argv
to_ip = ''
try:
    opts, args = getopt.getopt(argv[1:], "ht:",["help","targetIp="])
except getopt.GetoptError:
    print argv[0]+" -t <targetIp>"
    sys.exit(2)
for opt_name, opt_value in opts:
    if opt_name in ('-h','help'):
        print

data_pattern = re.compile(r"""^(.*?)((19|20)\d\d*)(.*?)$""", re.VERBOSE)
newest_file_data = 0

for folderName, subfolders, filenames in os.walk('/data0/sql_bak/'):
    for file_name in filenames:

        if re.match("\w*_3306.sql",file_name):
            mo = data_pattern.search(file_name)
            if mo == None:
                continue
            data_stamp = mo.group(2)
            if data_stamp > newest_file_data:
                newest_file_data = data_stamp

newest_file_name = "/data0/sql_bak/" + str(newest_file_data) + "_3306.sql"
print "I will copy newest file to server, file=" + newest_file_name
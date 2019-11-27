#! /usr/bin/python
# -*-coding=utf8-*-
# @Auther: Yao Shuai

# 文件名的格式形如 20191029151747_3306.sql 一定带一个_3306和一个日期时间的前缀
import os, shutil, sys, getopt
import re

argv = sys.argv
to_ip = ''
from_name = ''
from_port = ''
try:
    opts, args = getopt.getopt(argv[1:], "ht:n:p:",["help","targetIp=","serverName=","port="])
except getopt.GetoptError:
    print argv[0]+" -n <this server name> -t <targetIp> -p <port>"
    sys.exit(2)
for opt_name, opt_value in opts:
    print opt_name, opt_value
    if opt_name in ('-h','help'):
        print argv[0] + " -n <this server name> -t <targetIp> -p <port>"
        exit(1)
    if opt_name in ('-t', 'targetIp'):
        to_ip = opt_value
    if opt_name in ('-n', 'serverName'):
        from_name = opt_value
    if opt_name in ('-p', 'port'):
        from_port = opt_value

data_pattern = re.compile(r"""^(.*?)((19|20)\d\d*)(.*?)$""", re.VERBOSE)
newest_file_data = 0

need_search_files_pattern = "\w*_%s.sql" % str(from_port)
for folderName, subfolders, filenames in os.walk('/data0/sql_bak/'):
    for file_name in filenames:
        if re.match(need_search_files_pattern, file_name):
            mo = data_pattern.search(file_name)
            if mo == None:
                continue
            data_stamp = mo.group(2)
            if data_stamp > newest_file_data:
                newest_file_data = data_stamp

newest_file_name = "/data0/sql_bak/" + str(newest_file_data) + "_"+str(from_port)+".sql"
print "I will copy newest file to server, file=" + newest_file_name
os.system("echo scp %s root@%s:/data0/src/%s" % (newest_file_name, to_ip, from_name+"_"+str(newest_file_data))+"_"+str(from_port)+".sql")
#os.system("scp %s root@%s:/data0/src/%s" % (newest_file_name, to_ip, from_name+"_"+str(newest_file_data))+"_"+str(from_port)+".sql")
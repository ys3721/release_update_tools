#! /usr/bin/python
# -*-coding=utf8-*-
# @Auther: Yao Shuai

# 文件名的格式形如 20191029151747_3306.sql 一定带一个_3306和一个日期时间的前缀
import os, shutil, sys, getopt, logging
import re

logger = logging.getLogger()
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s-%(levelname)s-%(message)s')

argv = sys.argv
to_ip = ''
from_name = ''
from_port = ''
password = ''

try:
    opts, args = getopt.getopt(argv[1:], "ht:n:p:P:", ["help", "targetIp=", "serverName=", "port=", "password="])
except getopt.GetoptError:
    print argv[0]+" -n <this server name> -t <targetIp> -p <this server port> -P <target server password>"
    sys.exit(2)
for opt_name, opt_value in opts:
    if opt_name in ('-h','help'):
        print argv[0] + " -n <this server name> -t <targetIp> -p <this server port> -P <target server password>"
        exit(1)
    if opt_name in ('-t', 'targetIp'):
        to_ip = opt_value
    if opt_name in ('-n', 'serverName'):
        from_name = opt_value
    if opt_name in ('-p', 'port'):
        from_port = opt_value
    if opt_name in ('-P', 'password'):
        password = opt_value

logger.info("to ip=%s, from_name=%s, from_port=%s, password=%s" % (to_ip, from_name, from_port, password))

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
logger.debug("I will copy newest file to server, file=" + newest_file_name)
os.system("echo scp %s root@%s:/data0/src/%s" % (newest_file_name, to_ip, from_name+"_"+str(newest_file_data))+"_"+str(from_port)+".sql")
os.system("sshpass -p %s scp %s root@%s:/data0/src/%s" % (password, newest_file_name, to_ip, from_name+"_"+str(newest_file_data))+"_"+str(from_port)+".sql")
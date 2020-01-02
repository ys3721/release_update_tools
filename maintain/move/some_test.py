#! /usr/bin/python
# -*-coding=utf8-*-
# @Auther: Yao Shuai

import os
import subprocess

sql_name = os.system("sshpass -p 321 ssh root@10.10.6.14 ls /data0/src/s1145_*")
print "os.system.result=" + str(sql_name)

result = os.popen("sshpass -p 321 ssh root@10.10.6.14 ls /data0/src/s1145_*").readline()
print result

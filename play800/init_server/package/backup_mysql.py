# vim: tabstop=4 shiftwidth=4 softtabstop=4

# Copyright 2010 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# Copyright 2011 Justin Santa Barbara
# All Rights Reserved.
# Copyright (c) 2010 Citrix Systems, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.


import os,sys,time,fcntl,struct,stat
import commands
import traceback
import socket
import shutil
import sys

try:
    from hashlib import md5
except:
    from md5 import md5




def logging(item,level,mes):
    logpath = '/var/log/kxtools/'
    if not os.path.exists(logpath):
        os.makedirs(logpath)
    fp = open('%s/kxbackup.log'%logpath,'a')
    fp.write('%s - %s - %s - %s \n'%(time.ctime(),item,level,mes))
    fp.close()



"""Access file md5 value"""
def MD5(fname):
    filemd5 = ""
    try:
        file = open(fname, "rb")
        md5f = md5()
        strs = ""
        while True:
            strs = file.read(8096)
            if not strs:
                break
            md5f.update(strs)
        filemd5 = md5f.hexdigest()
        file.close()
        return filemd5
    except:
        logging('MySQL backup','ERROR',traceback.format_exc())

def get_em_ipaddr(dev):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    IP = socket.inet_ntoa(fcntl.ioctl(
           s.fileno(),
           0x8915,  # SIOCGIFADDR
           struct.pack('24s',dev)
    )[20:24])
    return IP

def tracert(ip):
    print ip
    count = 0
    for t in range(10):
        sock=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        sock.settimeout(10)
        try:
            sock.connect((ip,873))
            count += 1
        except socket.error,e:
            pass
        time.sleep(1)

    if count >= 6:
        return 0
    else:
        return 1

def IPADDR():
    """
    Get host name, ip
    return(hostname, ip)
    """
    def _get_ipaddr():
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 8000))
            return s.getsockname()[0]
        except:
            logging('MySQL backup','ERROR',traceback.format_exc())
        s.close()
    return (socket.gethostname(), _get_ipaddr())

def COMM(cmd):
    # Call system commands
    try:
        x,y = commands.getstatusoutput(cmd)
        if x != 0:
            logging('MySQL backup','ERROR',y)
            print x,y,cmd
        return x,y
    except:
        logging('MySQL backup','ERROR',traceback.format_exc())

class BackupMySQLDB(object):
    def __init__(self,kwargs):
        version = 1.0
        self.kwargs = kwargs

    def deleteDB(self):
        if not os.path.exists(self.kwargs['backup_path']):
            os.mkdir(self.kwargs['backup_path'])
        # Keep the data backup before two days
        reserve = list()
        cctime = time.time()
        for f in os.listdir(self.kwargs['backup_path']):
            if f.find('gz') != -1:
                reserve.append(f)

        if not os.path.exists('/data0/reserve/'):
            os.makedirs('/data0/reserve/')

        for  x in reserve:
            f = '%s%s' %(self.kwargs['backup_path'],x)
            fctime =  os.stat(f).st_ctime
            if (cctime - fctime ) > 172800:
                shutil.move(f ,'/dev/null')
                mes = 'Delete file %s is oK'%f
                logging('MySQL backup','INFO',mes)

    def backupDB(self):
        # Dump MySQL db ,zip,rsync to server
        ctimes = time.strftime("%Y%m%d")
        namesql = '%s_%s_%s_%s.sql' %(ctimes,self.kwargs['wanip'], IPADDR()[1], self.kwargs['data'])
        fname = '%s%s.gz' %(self.kwargs['backup_path'],namesql)
        rsync_file = "%s/rsyncd.secrets"%self.kwargs['backup_path']

        if not os.path.exists(self.kwargs['backup_path']):
            os.makedirs(self.kwargs['backup_path'])

        # Create rsyncd secrets file
        fp = open(rsync_file,'w')
        fp.write("Dnjd866")
        fp.close()

        os.chmod(rsync_file,stat.S_IREAD+stat.S_IWRITE)

        # mysqldump file to /data0/backup/
        x, y  = COMM("/usr/local/mysql/bin/mysqldump -u%s -p%s -h%s -S %s --single-transaction --opt  %s > %s/%s"\
                %(self.kwargs['user'],self.kwargs['pass'],self.kwargs['host'], self.kwargs['socks'], self.kwargs['dbname'],self.kwargs['backup_path'],namesql))
        if x != 0:
            mes = ('mysqldump file %s is failure'%namesql)
            print('MySQL backup','ERROR',mes)
        else:
            mes = ('mysqldump file %s is oK'%namesql)
            print('MySQL backup','INFO',mes)

        os.chdir(self.kwargs['backup_path'])

        # Tar sql file
        x,y = COMM("tar -czvf %s.gz %s" %(namesql,namesql))
        if x != 0:
            mes = ('tar file %s is failure'%namesql)
            logging('MySQL backup','ERROR',mes)
        else:
            mes =('tar file %s is oK'%namesql)
            logging('MySQL backup','INFO',mes)

        # Create MD5 values
        md5 =  MD5(fname)
        newname = fname.split('.sql.gz')[0] + '_%s'%md5 + '.sql.gz'
        shutil.move(fname , newname)

        # Double section of IP network
        ips = IPADDR()[1]

        if tracert(self.kwargs['rsync_ip']) != 0:
            self.kwargs['rsync_ip'] = self.kwargs['rsync_ip2']

        # Rsync to server 192.168.223.51
        # x, y = COMM("rsync --password-file=%s -avz %s  yttx@%s::%s/" %(rsync_file, newname,self.kwargs['rsync_ip'],self.kwargs['rsync_model']))
        x, y = COMM("rsync -avz %s  %s::%s/" %(newname,self.kwargs['rsync_ip'],self.kwargs['rsync_model']))
        if x != 0:
            mes = "rsync file %s.gz is failure" %newname
            logging('MySQL backup','ERROR',mes)
        else:
            mes = "rsync file %s.gz to %s is oK" %(newname,self.kwargs['rsync_ip'])
            logging('MySQL backup','INFO',mes)


        # Delete sql file
        shutil.move(namesql,'/dev/null')

    def dev_null_chmod(self):
        os.chmod("/dev/null", stat.S_IREAD|stat.S_IWRITE|stat.S_IRGRP|stat.S_IWGRP|stat.S_IROTH|stat.S_IWOTH)

    def work(self):
        self.deleteDB()
        self.backupDB()
        self.dev_null_chmod()

if __name__ == "__main__":
    if os.path.isdir("/data0/mysql"):
        kwargs = {
            'user': 'root',
            'pass': 'xssx1by',
            'host': '127.0.0.1',
            'dbname': 'wg_lj',
            'rsync_ip': '10.0.0.120',
            'rsync_ip2': '120.92.168.148',
            'rsync_model': 'backup',
            'backup_path': '/data0/backup/',
            'socks': '/var/lib/mysql/mysql.sock',
            'data': 'data0',
            'wanip': '134.175.233.30'
        }
        sc1 = BackupMySQLDB(kwargs)
        sc1.work()
        print 'data0 is ok!'
        time.sleep(32)
    if os.path.isdir("/data1/mysql"):
        kwargs2 = {
            'user': 'root',
            'pass': 'xssx1by',
            'host': '127.0.0.1',
            'dbname': 'wg_lj',
            'rsync_ip': '10.0.0.120',
            'rsync_ip2': '120.92.168.148',
            'rsync_model': 'backup',
            'backup_path': '/data0/backup/',
            'socks': '/var/lib/mysql3307/mysql.sock',
            'data': 'data1',
            'wanip': '134.175.233.30'
        }
        sc2 = BackupMySQLDB(kwargs2)
        sc2.work()
        print 'data1 is ok!'
        time.sleep(10)
    if os.path.isdir("/data5/mysql"):
        kwargs3 = {
            'user': 'root',
            'pass': 'xssx1by',
            'host': '127.0.0.1',
            'dbname': 'wg_lj',
            'rsync_ip': '10.0.0.120',
            'rsync_ip2': '120.92.168.148',
            'rsync_model': 'backup',
            'backup_path': '/data0/backup/',
            'socks': '/var/lib/mysql3308/mysql.sock',
            'data': 'data5',
            'wanip': '134.175.233.30'
        }
        sc3 = BackupMySQLDB(kwargs3)
        sc3.work()
        print 'data5 is ok!'
        time.sleep(16)
    if os.path.isdir("/data6/mysql"):
        kwargs4 = {
            'user': 'root',
            'pass': 'xssx1by',
            'host': '127.0.0.1',
            'dbname': 'wg_lj',
            'rsync_ip': '10.0.0.120',
            'rsync_ip2': '120.92.168.148',
            'rsync_model': 'backup',
            'backup_path': '/data0/backup/',
            'socks': '/var/lib/mysql3309/mysql.sock',
            'data':'data6',
            'wanip': '134.175.233.30'
        }
        sc4 = BackupMySQLDB(kwargs4)
        sc4.work()
        print 'data5 is ok!'
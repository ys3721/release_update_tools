import paramiko
import sys

hostname='10.10.9.25'
username='root'
password='P7QQQo5o1yx9'

if __name__=='__main__':
    ip = sys.argv[1]
    if len(ip) > 3:
        hostname = ip
    else:
        print "please input IP"
        exit
    s = paramiko.SSHClient()
    s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    s.connect(hostname = hostname,username=username, password=password)
    s.exec_command('wget http://10.10.6.140:8080/metricbeat.tar')
    s.close()
    s = paramiko.SSHClient()
    s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    s.connect(hostname = hostname,username=username, password=password)
    stdin, stdout, stderr = s.exec_command('tar -zxvf metricbeat.tar')
    print stdout.read()
    s.close()

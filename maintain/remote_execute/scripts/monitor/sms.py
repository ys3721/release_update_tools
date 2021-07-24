#!/usr/bin/env python
# --*-- coding:utf8 --*--

import sys, urllib, time, hashlib

def ShowMenu():
    menu = '''
	./sms.py mobile content
	./sms.py 13426332010 test
'''	    
    print '#' * 10
    print menu
    print '#' * 10
    
def GetStringMd5(str):
    h = hashlib.md5(str)
    return h.hexdigest()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        ShowMenu()
    else:
	#get localtime
	ltime = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))

	#get values

	mobile = str(sys.argv[1])
	content = urllib.quote(str(sys.argv[2]))
	md5key = GetStringMd5(mobile+'ASDxcv8234sfsj12'+time.strftime('%y-%m',time.localtime(time.time())))
	apiurl = 'http://interface.kaixin001.com/interface/sms/send.php?mobile=%s&content="%s"&sig=%s&subnum=566002&monitor=base'

	f = urllib.urlopen(apiurl % (mobile, content, md5key))

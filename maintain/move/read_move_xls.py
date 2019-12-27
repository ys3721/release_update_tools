#! /usr/bin/python
# -*-coding=utf8-*-
# @Auther: Yao Shuai

from sys import argv
import logging
import xlrd, os, time
from server_info import MoveServerInfo

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger("copy_sql")
logger.setLevel(logging.DEBUG)

file_name = './moveserver.xlsx'
center_config_path = '/data0/wg_center/WEB-INF/classes/'
data2_server_path = '/data2/servers/'

password = raw_input("请输入服务器的root密码！>")
servers = []


def read_excel():
    """读玉照给的xlsx然后把sql自动烤了吧"""
    wb = xlrd.open_workbook(filename=file_name)
    sheet0 = wb.sheet_by_index(0)
    row_size = len(sheet0.col_values(0))
    logger.info("Begin read the moveserver.xls !! row size is " + str(row_size))
    print row_size
    #不要头
    for i in range(1, row_size):
        row_cells = sheet0.row_values(i);
        server_name_pre = str(row_cells[0]).lower()
        server_name = row_cells[1].encode("utf-8")
        serverId = int(row_cells[2])
        before_wan_ip = str(row_cells[3])
        before_lan_ip = str(row_cells[4])
        before_mysql_port = int(row_cells[5])
        before_conn_port = int(row_cells[6])
        target_wan_ip = str(row_cells[7])
        target_lan_ip = str(row_cells[8])
        target_mysql_port = int(row_cells[9])
        target_conn_port = int(row_cells[10])

        server_info = MoveServerInfo(server_name_pre, server_name, serverId, before_wan_ip, before_lan_ip, before_mysql_port,
                                     before_conn_port, target_wan_ip, target_lan_ip, target_mysql_port, target_conn_port)
        servers.append(server_info)

    for i in range(0, len(servers)):
        if logger.isEnabledFor(logging.DEBUG):
            logger.debug(servers[i].server_name_pre)


def copy_dump_sql():
    """把文件读取表的文件传到before服务器 然后执行python copy_sql_to_loader.py脚本  就可以了"""
    for i in range(0, len(servers)):
        server = servers[i]
        logger.debug("scp copy_sql_to_loader.py root@%s:~" % server.before_lan_ip)
        os.system("scp copy_sql_to_loader.py root@%s:~" % server.before_lan_ip)
        logger.debug("Install sshpass to the target server %s" % server.before_lan_ip)
        os.system("ssh root@%s yum -y install sshpass" % server.before_lan_ip)
        logger.debug("ssh root@%s python copy_sql_to_loader.py -n%s -t%s -p%s -P%s" % \
              (server.before_lan_ip, server.server_name_pre, server.target_lan_ip, server.before_mysql_port, password))
        os.system("ssh root@%s python copy_sql_to_loader.py -n%s -t%s -p%s -P%s" %
                  (server.before_lan_ip, server.server_name_pre, server.target_lan_ip, server.before_mysql_port, password))

def del_center_server_config():
    with open(center_config_path+"gameserver.xml", 'r+') as file_object:
        lines = file_object.readlines()
        time_str = time.strftime("%Y%m%d%H%M%S")
        with open(center_config_path+"gameserver_"+time_str+".xml", 'w') as back_file_obj:
            back_file_obj.writelines(lines)
        # Remove the old config from the gameserver xml, on add server script new one will add back to the file.
        for i in range(len(lines) - 1, -1, -1):
            line = lines[i]
            if is_line_contain_server(line):
                del_line = lines.pop(i)
                logger.info("Will delete line " + del_line)
        file_object.seek(0)
        file_object.truncate()
        file_object.writelines(lines)


def is_line_contain_server(line):
    if len(line) == 0:
        return False
    if str.isspace(line):
        return False
    for i in range(0, len(servers)):
        server = servers[i]
        if '"'+server.before_lan_ip+'"' in line:
            logger.debug('"'+server.before_lan_ip+'"' + "is in line will delete!!!")
            return True
    return False


def modify_server_txt():
    for server in servers:
        try:
            with open(data2_server_path + server.server_name_pre+".config", 'r+') as data2_server_config_file:
                config_content = data2_server_config_file.readline()
                logger.debug("Begin process data2/servers "+server.server_name_pre+".config -->" + config_content)
                config_content = config_content.replace(" "+server.before_lan_ip+" ", " "+server.target_lan_ip+" ")
                config_content = config_content.replace(" "+server.before_wan_ip+" ", " "+server.target_wan_ip+" ")
                data2_server_config_file.seek(0)
                data2_server_config_file.truncate()
                data2_server_config_file.write(config_content)
        except IOError:
            logger.error(server.server_name_pre + "not exist!!")


def install_new_server():
    new_server_contain = {}
    for server in servers:
        if server.target_lan_ip not in new_server_contain.keys():
            new_server_contain[server.target_lan_ip] = []
            new_server_contain[server.target_lan_ip].append(server)
        else:
            new_server_contain[server.target_lan_ip].append(server)
    for key, value in new_server_contain.items():
        # lamda 表达式的 排序实现
        value.sort(lambda s1, s2: cmp(s1.target_mysql_port, s2.target_mysql_port))
        server_param = ""
        for server in value:
            server_param += " "+server.server_name_pre
        logger.info("Begin install new server ---> cpython add_some_server.py %s" % server_param)
        #os.system("cd /data3/init_server/ && python add_some_server.py %s" % server_param)


def fill_sql_to_mysql():
    for server in servers:
        print server.server_name_pre

        
read_excel()
del_center_server_config()
modify_server_txt()
copy_dump_sql()
#install_new_server()
#fill_sql_to_mysql()

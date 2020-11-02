#! /usr/bin/python
# -*-coding=utf8-*-
# @Auther: Yao Shuai

import os
import sys
import re
import commands
import traceback
import time

#改
GAME_ID = 5724
LOCALHOST_CENTER_IP = '139.199.12.180'

# 这个配置不是常量 需要修改用手，而且要和install mysql的脚步对应上
DB_PASSWORD_CONFIG = {"sys_user": "root", "sys_password": "xssx1by",
                      "game_user": "sgqyh5", "game_password": "mRYsETp5U3xh",
                      "gm_user": "gmroot", "gm_password": "M4BsaVivm2XI",
                      }

# 常量一般不用修改
MEMORY_CONFIG = {"1": {"game_server_memory": '8560', "log_server_memory": '1212'},
                 "2": {"game_server_memory": '4096', "log_server_memory": '819'},
                 "3": {"game_server_memory": '3072', "log_server_memory": '512'},
                 "4": {"game_server_memory": '2304', "log_server_memory": '448'}
                 }
# 约定常量一般不用修改
DEFAULT_CONFIG = [{'path': '/data0', 'mysql_port': '3306', 'game_port': '8080', 'telnet_port' : '7000',
                   'log_port': '8083', 'ex_port': "6060"},
                  {'path': '/data1', 'mysql_port': '3307', 'game_port': '8307', 'telnet_port' : '7307',
                   'log_port': '8007', 'ex_port': "6307"},
                  {'path': '/data5', 'mysql_port': '3308', 'game_port': '8308', 'telnet_port' : '7308',
                   'log_port': '8008', 'ex_port': "6308"},
                  {'path': '/data6', 'mysql_port': '3309', 'game_port': '8309', 'telnet_port' : '7309',
                   'log_port': '8009', 'ex_port': "6309"}]

def execute_command(cmd):
    # Call system commands
    try:
        x,y = commands.getstatusoutput(cmd)
        if x != 0:
            print x,y,cmd
        return x,y
    except:
        print('MySQL backup','ERROR',traceback.format_exc())

def read_config_file(file_name):
    server_config_file_path = "/data2/servers/" + file_name+".config"
    config_file = open(server_config_file_path, 'r')
    config_line = config_file.read()
    config_split = re.split("\\s", config_line)
    return config_split


def assemble(index, configs, total_count):
    """
        组装成一个完整的字典
    """
    deploy_config_dic = {}
    deploy_config_dic["server_id"] = configs[0]
    deploy_config_dic["region_id"] = configs[1]
    deploy_config_dic["domain"] = configs[2]
    deploy_config_dic["domain_prefix"] = deploy_config_dic["domain"].split(".")[0]
    deploy_config_dic["lan_ip"] = configs[3]
    deploy_config_dic["wan_ip"] = configs[4]
    deploy_config_dic["server_name"] = configs[5]
    deploy_config_dic["turnOnCenter"] = configs[6]
    deploy_config_dic["mysql_port"] = DEFAULT_CONFIG[index]['mysql_port']
    deploy_config_dic["game_port"] = DEFAULT_CONFIG[index]['game_port']
    deploy_config_dic["telnet_port"] = DEFAULT_CONFIG[index]['telnet_port']
    deploy_config_dic["log_port"] = DEFAULT_CONFIG[index]['log_port']
    deploy_config_dic["path"] = DEFAULT_CONFIG[index]['path']
    deploy_config_dic["ex_port"] = DEFAULT_CONFIG[index]['ex_port']

    deploy_config_dic["sys_user"] = DB_PASSWORD_CONFIG['sys_user']
    deploy_config_dic["sys_password"] = DB_PASSWORD_CONFIG['sys_password']
    deploy_config_dic["game_user"] = DB_PASSWORD_CONFIG['game_user']
    deploy_config_dic["game_password"] = DB_PASSWORD_CONFIG['game_password']
    deploy_config_dic["gm_user"] = DB_PASSWORD_CONFIG['gm_user']
    deploy_config_dic["gm_password"] = DB_PASSWORD_CONFIG['gm_password']

    deploy_config_dic["game_server_memory"] = MEMORY_CONFIG[total_count]['game_server_memory']
    deploy_config_dic["log_server_memory"] = MEMORY_CONFIG[total_count]['log_server_memory']
    return deploy_config_dic


def auth_server(lang_ip):
    """
    这个地方应该改成用那个带回显的命令方式，可以参照back mysql中的内容
    """
    PASSWORD = raw_input('Input the password>\n')
    no_host_check_cmd = 'sshpass -p "%s" ssh %s -o StrictHostKeyChecking=no ls' % (PASSWORD, lang_ip)
    print 'execute -------------------> ' + no_host_check_cmd
    os.system(no_host_check_cmd)
    mk_ssh_dir_cmd = 'sshpass -p "%s" ssh %s mkdir -p .ssh' % (PASSWORD, lang_ip)
    print 'execute--------------> ' + mk_ssh_dir_cmd
    os.system(mk_ssh_dir_cmd)
    authorize_cmd = """cat ~/.ssh/id_rsa.pub | sshpass -p "%s" ssh root@%s 'cat >> .ssh/authorized_keys'""" % (PASSWORD, lang_ip)
    print 'execute--> ' + authorize_cmd
    os.system(authorize_cmd)


def generate_deploy_config(config_dictionary):
    """
         生成配置文件 deploy_config_hxxx.config
    """
    temp_file = open('./deploy_config.xml.template', 'r')
    deploy_config_template = temp_file.read()
    temp_file.close()
    for index in range(0, deploy_count):
        file_content = deploy_config_template + ""
        config_of_index = config_dictionary[index]
        gen_file_name = 'deploy_config_%s.xml' % config_of_index["server_name"]
        for key in config_of_index.keys():
            file_content = file_content.replace("#%s#" % key, config_of_index[key])
        if not os.path.isdir('./generated/'):
            os.mkdir("./generated")
        gen_file = open('./generated/' + gen_file_name, 'w')
        gen_file.write(file_content)
        gen_file.flush()
        gen_file.close()

def config_conform(config_dictionary_arr):
    print "将要为一个云服务器部署%d个游戏服！" % len(config_dictionary_arr)
    _lan_ip = ""
    _wan_ip = ""
    for _config in config_dictionary_arr:
        print "\n\n"
        print "服务器 %s" % _config["server_name"]
        print "server_name \t%s\n" % _config["server_name"]
        print "server_id \t %s" % _config["server_id"]
        print "region_id \t %s" % _config["region_id"]
        print "domain    \t%s" % _config["domain"]
        print "domain_prefix  %s" % _config["domain_prefix"]
        print "lan_ip    \t%s" % _config["lan_ip"]
        print "wan_ip    \t%s" % _config["wan_ip"]
        print "turnOnCenter \t%s\n" % _config["turnOnCenter"]

    _conform = raw_input("重要，确认是否正确！ 正确y，错误n\n")
    if _conform != "y":
        exit(1)


def generate_gm_xml(config_dictionary):
    # 生成配置文件 db_x.xml 到 gm后台的对应目录中
    db_temp_file = open("./gm_db.xml.template", 'r')
    db_config_template = db_temp_file.read()
    db_temp_file.close()
    for index in range(0, deploy_count):
        config_dic_by_index = config_dictionary[index]
        db_config_file_name = "%s_db.xml" % config_dic_by_index["server_name"]
        db_config_content = db_config_template + ""
        for key in config_dic_by_index:
            db_config_content = db_config_content.replace("#%s#" % key, config_dic_by_index[key])

        write_db_file = open("./generated/" + db_config_file_name, 'w')
        write_db_file.write(db_config_content)
        write_db_file.flush()
        write_db_file.close()


def copy_depends(config_dictionary):
    ip = config_dictionary[0]['lan_ip']
    os.system("ssh root@%s 'mkdir -p /data0/'" % ip)
    os.system("/usr/bin/scp package/jdk7.zip root@%s:/data0" % ip)
    os.system("/usr/bin/scp package/backup_mysql.py root@%s:/data0/backup_mysql.py" % ip)
    os.system("/usr/bin/scp package/install_mysql.py root@%s:/data0/install_mysql.py" % ip)
    os.system("/usr/bin/scp ~/.bash_profile root@%s:~/.bash_profile" % ip)
    #os.system("/usr/bin/scp package/install_server.py root@%s:/data0/install_server.py" % ip)

    for config in config_dictionary:
        os.system("ssh root@%s 'mkdir -p %s/wg_deploy'" % (ip, config['path']))
        os.system("scp package/deploy_tools.zip root@%s:%s/wg_deploy" % (ip, config['path']))
        os.system("scp package/run_deploytool.sh root@%s:%s/wg_deploy" % (ip, config['path']))
        os.system("scp package/deploy_current_path.sh root@%s:%s/wg_deploy" % (ip, config['path']))
        os.system("scp generated/deploy_config_%s.xml root@%s:%s/wg_deploy" % (config['server_name'], ip, config['path']))
        os.system("cp generated/%s_db.xml /data0/wg_gmserver/WEB-INF/classes/conf/db1" % config['server_name'])

def install_mysql(config_dic_array):
    count = len(config_dic_array)
    target_ip = config_dic_array[0]["lan_ip"]
    root_password = DB_PASSWORD_CONFIG["sys_password"]
    gm_ip = os.popen("ifconfig|grep 'inet '|grep -v '127.0'|xargs|awk -F '[ :]' '{print $3}'").readline().rstrip()
    gm_password = DB_PASSWORD_CONFIG["gm_password"]
    game_user = DB_PASSWORD_CONFIG["game_user"]
    game_passwrod = DB_PASSWORD_CONFIG["game_password"]
    install_mysql_cmd = "ssh root@%s 'python /data0/install_mysql.py %d %s %s %s %s %s'" % (target_ip, count, root_password, gm_ip, gm_password, game_user, game_passwrod)
    print install_mysql_cmd
    x, y = execute_command(install_mysql_cmd)
    print x
    print y


def upzip_jdk(config_dic_array):
    target_ip = config_dic_array[0]["lan_ip"]
    unzip_jdk = "ssh root@%s 'cd /data0 ; unzip -oq jdk7.zip'" % target_ip
    print unzip_jdk
    x, y = execute_command(unzip_jdk)
    print "run result status=%r" % x, y


def run_deploy_tool(config_dic_array):
    for _config_dic in config_dic_array:
        target_ip = _config_dic["lan_ip"]
        run_deploy = "ssh root@%s 'cd %s/wg_deploy ; unzip -o ./deploy_tools.zip ; chmod u+x ./run_deploytool.sh; ./run_deploytool.sh'" % (target_ip, _config_dic["path"])
        os.system(run_deploy)

def init_game_server(config_dic_array):
    cmd = "cd /data3/update_server ; ./sync_and_update.sh %s -ia" % config_dic_array[0]["server_name"]
    print cmd
    os.system(cmd)


def update_center_server_xml(config_dic_array):
    time_tag = int(time.time())
    os.system("cp /data0/wg_center/WEB-INF/classes/gameserver.xml /data0/wg_center/WEB-INF/classes/gameserver_%d.xml" % time_tag)
    _game_server_xml_file = open("/data0/wg_center/WEB-INF/classes/gameserver.xml", 'r');
    _content = _game_server_xml_file.read()
    for _config in config_dic_array:
        if _config["server_name"]+"-" in _content:
            continue
        _line = """<server ip="%s" port="%s" gameID="%d" serverID="%s"></server>   <!--%s-->""" % \
                (_config["lan_ip"], _config["telnet_port"], GAME_ID, _config["server_id"], _config["server_name"])
        _content = _content.replace("</servers>", _line+"\n</servers>")
    _will_write_file = open("/data0/wg_center/WEB-INF/classes/gameserver.xml", 'w');
    _will_write_file.write(_content)
    _will_write_file.flush()
    _will_write_file.close()
    os.system("curl http://%s:8090/game_center_server/local/reload.gameserverxml" % LOCALHOST_CENTER_IP)

def restart_gm():
    os.system("sh /data0/apache-tomcat-7.0.39/bin/shutdown.sh")
    time.sleep(15)
    os.system("sh /data0/apache-tomcat-7.0.39/bin/startup.sh")

"""
This script solve deploy multiply game server on one machine by args count
"""
server_config_files = sys.argv
deploy_count = len(server_config_files) - 1
deploy_config = []

for i in range(0, deploy_count):
    server_config_file_name = server_config_files[i + 1]
    config_dic = assemble(i, read_config_file(server_config_file_name), str(deploy_count))
    deploy_config.append(config_dic)

print deploy_config

conform = raw_input("确认开始部署服务器?hx.config已经填写完毕？ y/n")
if conform != 'y':
    exit(1)
# 授权
auth_server(deploy_config[0]['lan_ip'])
generate_deploy_config(deploy_config)
config_conform(deploy_config)
generate_gm_xml(deploy_config)
copy_depends(deploy_config)
install_mysql(deploy_config)
upzip_jdk(deploy_config)
run_deploy_tool(deploy_config)
update_center_server_xml(deploy_config)
init_game_server(deploy_config)
restart_gm()


#! /usr/bin/python
# -*-coding=utf8-*-
# @Auther: Yao Shuai

class MoveServerInfo(object):
    """服务器编号	服务器名字	serverID	迁移前IP	迁移前NIP	前数据端口	前访问端口	迁移后IP	迁移后NIP	后数据端口	后访问端口"""
    def __init__(self, server_name_pre, server_name, serverId, before_wan_ip, before_lan_ip, before_mysql_port,
                 before_conn_port, target_wan_ip, target_lan_ip, target_mysql_port, target_conn_port):
        """Initialize server move info attribute"""
        self.server_name_pre = server_name_pre
        self.server_name =server_name
        self.serverId = serverId
        self.before_wan_ip = before_wan_ip
        self.before_lan_ip = before_lan_ip
        self.before_mysql_port = before_mysql_port
        self.before_conn_port = before_conn_port
        self.target_wan_ip = target_wan_ip
        self.target_lan_ip = target_lan_ip
        self.target_mysql_port = target_mysql_port
        self.target_conn_port = target_conn_port

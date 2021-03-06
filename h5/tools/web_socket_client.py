#! /usr/bin/python
# -*-coding=utf8-*-
# @Auther: Yao Shuai
#这个是3.x的代码 所以在现在这个环境中会报错
#先这样今天不是处理这个事情的时候  2020-01-02 日子飞快哇。

from websocket import create_connection
from byte_utils import ByteBuffer

#hand_msg_int = 262654
#hand_msg_bytes = hand_msg_int.to_bytes(4, byteorder='big')
hand_msg_hex = b'\x00\x04\x01\xFE'
print(hand_msg_hex)

ws = create_connection("ws://192.168.0.173:8080")
print("send hand CG_HAND_SHARK msg...")
ws.send_binary(hand_msg_hex)
print("Receiving...")
result = ws.recv()
print("Received '%s', hand shake msg " % result)

#这里是用1和密码1这个账号登陆的
login_msg_bytes = b'\x01\x3E\x04\xB1\x00\x01\x31\x00\x01\x31\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x15\x75\x64\x69\x64\x2D\x66\x69\x78\x65\x64\x2D\x31\x32\x33\x34\x35\x36\x37\x38\x39\x30\x00\x05\x30\x2E\x30\x2E\x30\x00\x05\x7A\x68\x5F\x43\x4E\x00\x7C\x7B\x22\x70\x6C\x61\x74\x66\x6F\x72\x6D\x22\x3A\x32\x30\x2C\x22\x63\x68\x61\x6E\x6E\x65\x6C\x49\x64\x22\x3A\x22\x22\x2C\x22\x61\x70\x70\x49\x64\x22\x3A\x22\x22\x2C\x22\x6C\x6F\x67\x69\x6E\x53\x65\x72\x76\x65\x72\x49\x64\x22\x3A\x22\x31\x30\x31\x35\x22\x2C\x22\x6D\x61\x63\x22\x3A\x22\x22\x2C\x22\x69\x6D\x65\x69\x22\x3A\x22\x22\x2C\x22\x63\x6F\x6F\x70\x69\x64\x22\x3A\x22\x22\x2C\x22\x62\x75\x6E\x64\x6C\x65\x69\x64\x22\x3A\x22\x63\x6F\x6D\x2E\x69\x67\x61\x6D\x65\x2E\x73\x67\x71\x79\x7A\x22\x7D\x00\x00\x16\x00\x00\x00\x03\xF7\x00\x7C\x7B\x22\x70\x6C\x61\x74\x66\x6F\x72\x6D\x22\x3A\x32\x30\x2C\x22\x63\x68\x61\x6E\x6E\x65\x6C\x49\x64\x22\x3A\x22\x22\x2C\x22\x61\x70\x70\x49\x64\x22\x3A\x22\x22\x2C\x22\x6C\x6F\x67\x69\x6E\x53\x65\x72\x76\x65\x72\x49\x64\x22\x3A\x22\x31\x30\x31\x35\x22\x2C\x22\x6D\x61\x63\x22\x3A\x22\x22\x2C\x22\x69\x6D\x65\x69\x22\x3A\x22\x22\x2C\x22\x63\x6F\x6F\x70\x69\x64\x22\x3A\x22\x22\x2C\x22\x62\x75\x6E\x64\x6C\x65\x69\x64\x22\x3A\x22\x63\x6F\x6D\x2E\x69\x67\x61\x6D\x65\x2E\x73\x67\x71\x79\x7A\x22\x7D'
ws.send_binary(login_msg_bytes)
print("Receiving login result...")
result = ws.recv()
print("Received '%s', login result " % result)

#这里1这个账号已经有了 所以直接发 CG_ROLE_ENTER 1209
role_enter_msg_bytes = b'\x00\x08\x04\xB9\x04\x01\x00\x00\x00\x00\x07\xD1\x00\x00'
print("Send CG ROLE ENTER msg %r" % type(role_enter_msg_bytes))
ws.send_binary(role_enter_msg_bytes)
result = ws.recv()
print("Receive enter result %s" % result)

#这里发 CG_ENTER_GAME 就算是进入游戏了
enter_game_msg_byte =b'\x00\x06\x04\xC3\x00\x00'
print("Send CG_ENTER_GAME")
ws.send_binary(enter_game_msg_byte)
result = ws.recv()
print("Receive entry game result %s " % result)



ws.close()
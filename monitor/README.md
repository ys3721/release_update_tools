    目标： 监控机器是否宕机
    思路： 借助ES套件实现日志上报 并且写个定时脚本遍历主机日志上报情况 没有则宕机

### ES 配置

    见 elasticsearch 安装 配置.pdf

### Kibana 配置

    见 Kibana 安装 配置.pdf
    http://106.52.90.51:8309/app/metrics/inventory


###  metricbeat 安装配置
#### 下载 解压
![下载选择](/img/1.png)
![解压](/img/2.png)

这个每个主机都要整一个


#### 配置
```yml
# =================================== Kibana ================================
# Starting with Beats version 6.0.0, the dashboards are loaded via the Kibana
# This requires a Kibana endpoint configuration.
setup.kibana:
    # Kibana Host
    # Scheme and port can be left out and will be set to the default (http and
    # In case you specify and additional path, the scheme is required: http://l
    # IPv6 addresses should always be defined as: https://[2001:db8::1]:5601
    host: "ES所在IP:8309"
    # Kibana Space ID
    # ID of the Kibana Space into which the dashboards should be loaded. By def
    # the Default Space will be used.
    #space.id:
output.elasticsearch:
    # Array of hosts to connect to.
    hosts: ["ES所在IP:8308"]
    # Protocol - either `http` (default) or `https`.
    #protocol: "https"
    # Authentication credentials - either API key or username/password.
    #api_key: "id:api_key"
    #username: "elastic"
    #password: "changeme"
```

##### 启用收集模块
```shell
# 这个是启用监测模块用的 system默认开启
./metricbeat modules enable system
#对于配置文件   modules.d/system.yml
```

```
./metricbeat setup # 对于ES只执行一次
```

```
./metricbeat -e
```


#### 其他

在10.10.6.140执行这个文件 （开了tomcat下载）(目前只能这个服务器执行)
初始化新部署服务器 

```python
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
    s.exec_command('renice -n -5 $(lsof -i :22 | grep "*" | awk '{print $2}')')
    s.close()
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
    s = paramiko.SSHClient()
    s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    s.connect(hostname = hostname,username=username, password=password)
    stdin, stdout, stderr = s.exec_command('nohup /usr/local/metricbeat/metricbeat -e -c /usr/local/metricbeat/metricbeat.yml>console.log 2>&1 &')
    print stdout.read()
    s.close()
```

### 定时任务

#### Maven仓库

```Maven
<mirror>
    <id>aliyunmaven</id>
    <mirrorOf>*</mirrorOf>
    <name>阿里云公共仓库</name>
    <url>https://maven.aliyun.com/repository/public</url>
</mirror>
```

#### SpringBoot程序

    见 monitor 文件夹 运行在gm后台所在服务器 把 部署 文件夹整体上传，执行 start.sh 就可以了。
    配置在 config下的 application.yml 中

```yml
server:
  port: 8081 # 随意

scheduling:
  monitor: 0 */10 * * * ? # 每10分钟查询一遍
  filePath: /data2/servers  # 服务器列表所在位置
  webhook: https://www.feishu.cn/flow/api/trigger-webhook/f172ddd06840292d541a4aff3f5e192d , https://www.feishu.cn/flow/api/trigger-webhook/f172ddd06840292d541a4aff3f5e192d # webhook用逗号隔开可以多个
```

#### 飞书webhook配置

``` json
{
    "events":[
        {
            "data":1
        }
    ]
}
```

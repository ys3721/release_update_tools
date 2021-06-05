# "release_update_tools" 
## Some hand-written scripts. Used to maintain game servers.
+ Update release game package
+ Install multiple mysql instances,initialize previleges.
+ Install jdk mysql,deploy game servers.
+ Migrate game servers and more.

## 各种维护脚本的合集
### 有用的
#### 1.部署
sanqun/init_server/add_some_server.py
> 现在使用的脚本部署在 {ss服ip}/data3/init_server 下.

#### 2.合服启动脚本
maintain/merge/merge.sh
> 现在使用的脚本部署在 {ss服ip}/data3/merge 下.
这个合服启动脚本启动了项目中的merge project打包出的jar包。

#### 3.挪动服务器数据
move/read_move_xls.py
**注意这个需要运维配合改动server_list和绑定新的域名。具体问玉召吧。**
> 现在部署在ss的/data3/move_server下。要先修改该目录下的moveserver.xlsx。
```java 
 useage: python read_move_xls.py
```

#### 4.远程服务器执行脚本
remote_execute 目录下。
比如，要执行在s47执行当前目录下./scripts/echo_server_name.sh中的命令
```bash
execute_at_servers.sh ./scripts/echo_server_name.sh s47-s100
#或者 异步执行
async_batch.sh ./scripts/echo_server_name.sh s47-s100    
```
当然也可以在套一层scp先拷贝sh或者jar，然后再在目标服务器执行。
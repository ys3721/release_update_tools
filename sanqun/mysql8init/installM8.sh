wget https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.23-1.el7.x86_64.rpm-bundle.tar
tar -xvf ./mysql-8.0.23-1.el7.x86_64.rpm-bundle.tar -C ./mysql-bundle/

rpm -qa|grep -i mariadb
yum remove mariadb-libs-5.5.64-1.el7.x86_64
sudo yum install mysql-community-{server,client,common,libs}-*
grep 'temporary password' /var/log/mysqld.log

##https://dev.mysql.com/doc/refman/8.0/en/linux-installation-yum-repo.html
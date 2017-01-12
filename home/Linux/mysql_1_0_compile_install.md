##mysql编译安装

###1 创建mysql账号     
####创建mysql组  
```
groupadd -g 116 mysql            //查看/etc/group确认gid 116未被占用  
```
####创建mysql用户  
```
useradd -d /home/mysql -G mysql -g 116 -m -s /bin/bash mysql  
```
###2 安装cmake   
####获得cmake包
cmake.tar.gz
Ø  部署到 /usr/local
Ø  解压缩到 /usr/local目录
~#tar zxvf cmake.tar.gz
####配置cmake环境变量
```
~#vi /etc/profile

CMAKE_HOME=/usr/local/ cmake-3.1.3-Linux-x86_64

PATH=$CMAKE_HOME/bin:$PATH

export PATH
```
```
~#source /etc/profile
```
####检验cmake版本
```
linux6:/onip/ywx/mysql/mysql-5.5.53/data # cmake --version
cmake version 3.7.0

CMake suite maintained and supported by Kitware (kitware.com/cmake).
```
##预编译  
####获得mysql包
mysql-5.5.53.tar.gz
####创建目录

#####数据目录
```
mkdir /home/mysql/data
```
#####安装目录
```
mkdir /usr/local/mysql
```
#####预编译debug
```
time cmake . \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/onip/mysql/data \
-DMYSQL_UNIX_ADDR=/usr/local/mysql/mysql.sock \
-DMYSQL_USER=mysql \
-DCMAKE_BUILD_TYPE=Debug \
-DSYSCONFDIR=/etc \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci
```
```
time make
```
```
time make install
```
##初始化
```
cd $mysql/script
./mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/onip/mysql/data --defaults-file=/etc/my.cnf
faults-file=/etc/my.cnf
Installing MySQL system tables...
170112 15:58:22 [Note] Ignoring --secure-file-priv value as server is running with --bootstrap.
170112 15:58:22 [Note] /usr/local/mysql/bin/mysqld (mysqld 5.5.53-debug) starting as process 26950 ...
OK
Filling help tables...
170112 15:58:22 [Note] Ignoring --secure-file-priv value as server is running with --bootstrap.
170112 15:58:22 [Note] /usr/local/mysql/bin/mysqld (mysqld 5.5.53-debug) starting as process 26957 ...
OK

To start mysqld at boot time you have to copy
support-files/mysql.server to the right place for your system

PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !
To do so, start the server, then issue the following commands:

/usr/local/mysql/bin/mysqladmin -u root password 'new-password'
/usr/local/mysql/bin/mysqladmin -u root -h linux6 password 'new-password'

Alternatively you can run:
/usr/local/mysql/bin/mysql_secure_installation

which will also give you the option of removing the test
databases and anonymous user created by default.  This is
strongly recommended for production servers.

See the manual for more instructions.

You can start the MySQL daemon with:
cd /usr/local/mysql ; /usr/local/mysql/bin/mysqld_safe &

You can test the MySQL daemon with mysql-test-run.pl
cd /usr/local/mysql/mysql-test ; perl mysql-test-run.pl

Please report any problems at http://bugs.mysql.com/
```

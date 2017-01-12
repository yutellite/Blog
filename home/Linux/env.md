##环境配置

###1 home
####1.1 .bashrc
```
PATH=${HOME}/mysql-5.5.53/sql:${HOME}/mysql-5.5.53/client:${PATH}
alias mysqldir="cd /onip/mysql/mysql-5.5.53"
```
执行结果
```
mysql@linux6:~> mysqldir
mysql@linux6:~/mysql-5.5.53> 
```
####1.2 env.sh
```
alias mmp="ps -lu mysql | grep mysql | grep -v grep | grep -vE 'ps|bash|more|tail|cron'"
```
执行结果
```
mysql@linux6:~/mysql-5.5.53> mmp
0 S   109 119751  98132  0  80   0 - 61515 -      pts/3    00:00:06 mysqld
0 S   109 127327  45652  0  80   0 -  7363 -      pts/2    00:00:00 mysql
```

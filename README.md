## anp
```
1.更新说明
支持grpc依赖扩展grpc、protobuf

环境变量禁用opcache，通过设定ENABLE_OPCACHE=0禁用opcache

支持vim

更新gnu-libiconv解决php iconv的编码问题造成文件上传异常

2.环境变量支持
变量名	说明	默认值
APP_NAME	app名称（容器启动时会被自动加入）	-
APP_MODE	app所在集群名称（容器启动时会被自动加入）	-
APP_NETWORK_USE	app用途名称（容器启动时会被自动加入，包括：web、inner、job）	-
APP_PATH	项目所在目录（切勿修改）	/var/www/html
APP_PATH_INDEX	PHP项目index.php入口文件所在目录	/var/www/html
APP_PATH_404	PHP项目404.html文件所在目录	/var/www/html
APP_MONITOR_HOOK	app报警钉钉群机器人webhook	空
ENABLE_OPCACHE	是否启用opcache，默认开启，设置为0将不开启	1
NGINX_PHP_CONF	
default：支持yaf的nginx fastcgi配置

default
NGINX_LOCATION
特殊nginx location配置,如:rewrite、try_files或其它,如下Dockerfile中可以写为

ENV NGINX_LOCATION "location /web {try_files /web$uri $uri/ /index.php?$args;}"
（强烈建议您直接使用Dockerfile COPY来覆盖/etc/nginx/conf.d/default.conf文件来实现复杂跳转）

空
PHP_MEM_LIMIT
php单进程内存限制	
512M
PHP_POST_MAX_SIZE
php post最大字节	100M
PHP_UPLOAD_MAX_FILESIZE
php最大文件上传限制	100M
FPM_MAX_CHILDREN
fpm最大子进程数量	200
FPM_START_SERVERS
fpm初始子进程数量	10
FPM_MIN_SPARE_SERVERS
fpm最大空闲子进程数量	8
FPM_MAX_SPARE_SERVERS
fpm最小空闲子进程数量	15
FPM_MAX_REQUESTS
fpm每个子进程接受请求数量后会进行垃圾回收	200
FPM_SLOWLOG
fpm慢日志文件地址	
/var/log/fpm-slow.log
FPM_SLOWLOG_TIMEOUT
php-fpm慢日志超时时间(单位:秒)

2
3.软件版本
PHP 7.2.18 (cli) (built: May  4 2019 16:25:11) ( NTS )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies
    with Zend OPcache v7.2.18, Copyright (c) 1999-2018, by Zend Technologies

[PHP Modules]
amqp
apcu
bcmath
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
gmp
grpc
hash
iconv
igbinary
intl
json
ldap
libxml
mbstring
memcache
memcached
mongodb
mysqlnd
openssl
pcre
PDO
pdo_mysql
pdo_pgsql
Phar
posix
protobuf
rdkafka
readline
redis
Reflection
scws
session
SimpleXML
soap
sodium
SPL
standard
swoole
tokenizer
xml
xmlreader
xmlwriter
xsl
yaf
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache


nginx version: nginx/1.14.2

4.supervisor
anp中的所有后台任务都是由supervisord保活的，配置结构如下：

主配置文件：/supervisor.conf （该配置文件不允许被删除，否则会导致容器无法正常启动）

子配置文件：/etc/supervisor/init.conf （默认自带，用于启动环境变量APP_INIT_SHELL中的脚本内容）

子配置文件：/etc/supervisor/monitor.conf （默认自带，用于启动php-fpm进程数监控钉钉报警）

子配置目录：/etc/supervisor/*.conf  （supervisor会识别/etc/supervisor/目录下的所有conf文件）

友情连接：supervisor配置文件详解

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autostart=true
autorestart=true
startsecs=3
stdout_logfile=/dev/stdout
redirect_stderr=true
stdout_logfile_maxbytes=0

[program:php-fpm]
command=/usr/sbin/php-fpm7 --nodaemonize
autostart=true
autorestart=true
startsecs=3
stdout_logfile=/dev/stdout
redirect_stderr=true
stdout_logfile_maxbytes=0

[include]
files=/etc/supervisor/*.conf


[program:php-monitor]
command=php /extra/monitor/start.php
autostart=true
autorestart=true
startsecs=3
stdout_logfile=/dev/stdout
redirect_stderr=true
stdout_logfile_maxbytes=0
5.建议


1、我们强烈建议，覆盖/etc/supervisor/init.conf，放弃对于环境变量APP_INIT_SHELL的使用，转而进行/etc/supervisor/*.conf来实现你想要的初始化脚本执行，例如：


[program:my-init-shell]
directory=/var/www/html   #command会在当前目录下执行
command=php bin/cli init/index  #执行初始化命令，千万不要执行特殊的业务，因为容器每次部署都会执行
autostart=true   #是否自动启动
autorestart=false   #是否自动重启，true：保活退出后会自动启动，false：仅执行一次
startsecs=3
stdout_logfile=/dev/stdout
redirect_stderr=true
stdout_logfile_maxbytes=0
2、将您的conf文件放到镜像中

FROM harbor.eoffcn.com/base/anp:stable
COPY supervisor/my-init-shell.conf /etc/supervisor/my-init-shell.conf
3、开启supervisor web GUI

supervisor在daemon条件下运行

[inet_http_server]
port=127.0.0.1:9001


FROM harbor.eoffcn.com/base/anp:stable
COPY supervisor/web-gui.conf /etc/supervisor/web-gui.conf
```
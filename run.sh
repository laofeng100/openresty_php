#!/bin/bash

mkdir -p /run/nginx

#IP
IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
#容器ID
CONTAINER_ID=${HOSTNAME}
supervisord -c /supervisor.conf
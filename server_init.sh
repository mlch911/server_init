#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 7+
#	Description: 服务器初始化脚本
#	Version: 0.1.1
#	Author: 壕琛
#	Blog: http://mluoc.top/
#=================================================

yum -y install wget nano docker
yum -y update
github="https://git.mluoc.tk/mlch911/server_init/raw/branch/master"
dir="/root/.ssh"
file="authorized_keys"
cd /root
wget --no-check-certificate -qO- -O ssh_pub_keys ${github}/ssh_pub_keys

if test ! -e ${dir}
	then mkdir ${dir}
	chmod +x ${dir}
fi
if test ! -e ${dir}/${file}
	then touch ${dir}/${file}
	chmod +x ${dir}/${file}
fi
cat /root/ssh_pub_keys | while read line; do echo ${line} >> ${dir}/${file} ; done
# docker run -d --name=speedtest -p 6688:80 ilemonrain/html5-speedtest:alpine
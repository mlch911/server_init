#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 7+
#	Description: 服务器初始化脚本
#	Version: 0.1.6
#	Author: 壕琛
#	Blog: http://mluoc.top/
#=================================================

yum -y install wget nano git unzip
yum -y update
github="https://git.mluoc.tk/mlch911/server_init/raw/branch/master"
dir="/root/.ssh"
file="authorized_keys"
cd /root
mkdir ssh_pub_keys
wget --no-check-certificate -qO- -O ssh_pub_keys ${github}/ssh_pub_keys

# if test ! -e ${dir}
# 	then mkdir ${dir}
# 	chmod +x ${dir}
# fi
# if test ! -e ${dir}/${file}
# 	then touch ${dir}/${file}
# 	chmod +x ${dir}/${file}
# fi
cat /root/ssh_pub_keys | while read line; do echo ${line} >> ${dir}/${file} ; done
# docker run -d --name=speedtest -p 6688:80 ilemonrain/html5-speedtest:alpine

# 更改ssh端口
read -p "是否更改ssh端口 :(y/n)" input_a
if [ ${input_a} == "y" ] ;then
	cd /etc/ssh/
	read -p "新的ssh端口 :" ssh_port
	sed -i "17c Port ${ssh_port}" sshd_config
	read -p "修改完成，是否开放防火墙 :(y/n)" input_b
	if [ ${input_b} == "y" ] ;then
		echo -e " 请选择防火墙类型 :
		${Green_font_prefix}1.${Font_color_suffix} firewalld
		${Green_font_prefix}2.${Font_color_suffix} iptables
		————————————————————————————————"
		read -p "请输入数字 :" num
		if [ ${num} == "1" ] ;then
			firewall-cmd --permanent --zone=public --add-port=${ssh_port}/tcp
			firewall-cmd --permanent --zone=public --add-port=${ssh_port}/udp
			firewall-cmd --reload
		elif [ ${num} == "2" ] ;then
			iptables -A INPUT -p tcp --dport ${ssh_port} -j ACCEPT
			iptables -A INPUT -p udp --dport ${ssh_port} -j ACCEPT
			service iptables save
			service iptables restart
		fi
	fi
	read -p "是否重启ssh服务 :(y/n)" input_c
	if [ ${input_c} == "y" ] ;then
		systemctl restart sshd.service
	fi
	echo -e "ssh端口更改完成！"
fi

clear
echo -e "Server initialzation finished!"
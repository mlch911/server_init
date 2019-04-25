#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 7+
#	Description: 服务器初始化脚本
#	Version: 0.3.0
#	Author: 壕琛
#	Blog: http://mluoc.top/
#=================================================

# ftp_init(){
# 	read -p "请输入该服务器的ip或域名 :" server_ip
# 	read -p "请确认该服务器的ip或域名是否为 ${server_ip} :(y/n)" input_f
# 	if [ ${input_f} == "y" ] ;then
# 		docker run -d -v /root/vsftpd:/home/vsftpd -p 20:20 -p 21:21 -p 47400-47470:47400-47470 -e FTP_USER=mlch911 -e FTP_PASS=mlch1995123 -e PASV_ADDRESS=139.180.141.30 --name ftp --restart=always bogem/ftp
# 	elif [ ${input_f} == "n" ] ;then
# 		return 1
# 	else
# 		ftp_init
# 	fi

# 	#开放防火墙
# 	read -p "修改完成，是否开放防火墙 :(y/n)" input_g
# 	if [ ${input_g} == "y" ] ;then
# 		echo -e " 请选择防火墙类型 :
# 		${Green_font_prefix}1.${Font_color_suffix} firewalld
# 		${Green_font_prefix}2.${Font_color_suffix} iptables
# 		————————————————————————————————"
# 		read -p "请输入数字 :" num
# 		if [ ${num} == "1" ] ;then
# 			firewall-cmd --permanent --zone=public --add-port=21/tcp
# 			firewall-cmd --permanent --zone=public --add-port=21/udp
# 			firewall-cmd --reload
# 		elif [ ${num} == "2" ] ;then
# 			iptables -A INPUT -p tcp --dport 21 -j ACCEPT
# 			iptables -A INPUT -p udp --dport 21 -j ACCEPT
# 			service iptables save
# 			service iptables restart
# 		fi
# 	fi

# 	echo -e "ftp服务安装完成！"
# }

yum -y install wget nano git unzip
yum -y update
github="https://git.mluoc.tk/mlch911/server_init/raw/branch/master"
dir="/root/.ssh"
file="authorized_keys"
cd /root
mkdir .ssh
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
			iptables -A INPUT -p tcp --dport 21 -j ACCEPT
			iptables -A INPUT -p udp --dport 21 -j ACCEPT
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

# #ftp服务
# read -p "是否安装ftp服务 :(y/n)" input_d
# if [ ${input_d} == "y" ] ;then
# 	cd /root
# 	mkdir vsftpd
# 	ftp_init
# fi

clear
echo -e "Server initialzation finished!"
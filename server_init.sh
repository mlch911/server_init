PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 7+
#	Description: 服务器初始化脚本
#	Version: 0.4.0
#	Author: 壕琛
#	Blog: http://mluoc.top/
#=================================================

sh_ver="0.4.0"
github="https://git.mluoc.tk/mlch911/server_init/raw/branch/master"
file="authorized_keys"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"



#开始菜单
start_menu(){
	clear
	echo && echo -e " ssrpanel后端 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
	  -- 壕琛小站 | ss.mluoc.tk --

	 ${Green_font_prefix}0.${Font_color_suffix} 升级脚本
	 ${Green_font_prefix}1.${Font_color_suffix} 初始化
	 ${Green_font_prefix}2.${Font_color_suffix} 更改ssh端口
	 ${Green_font_prefix}3.${Font_color_suffix} 安装zsh
	 ${Green_font_prefix}4.${Font_color_suffix} 开放防火墙
	 ${Green_font_prefix}5.${Font_color_suffix} 待添加
	 ${Green_font_prefix}6.${Font_color_suffix} 待添加
	 ${Green_font_prefix}7.${Font_color_suffix} 退出脚本
	————————————————————————————————" && echo

		sh_new_ver=$(wget --no-check-certificate -qO- "${github}/server_init.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
		if [[ ${sh_new_ver} != ${sh_ver} ]]; then
			Update_Shell
		fi


	echo
	read -p " 请输入数字 [0-8]:" num
	case "$num" in
		0)
		Update_Shell
		;;
		1)
		Init_Shell
		;;
		2)
		SSH_port_change_Shell
		;;
		3)
		ZSH_install_Shell
		;;
		4)
		Firewalld_Shell
		;;
		5)
		start_menu
		;;
		6)
		start_menu
		;;
		7)
		exit 1
		;;
		*)
		clear
		echo -e "${Error}:请输入正确数字 [0-7]"
		sleep 2s
		start_menu
		;;
	esac
}

#更新脚本
Update_Shell(){
	echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
	sh_new_ver=$(wget --no-check-certificate -qO- "${github}/server_init.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && sleep 2s && start_menu
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
		read -p "(默认: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			wget -N --no-check-certificate ${github}/server_init.sh && chmod +x ss-node-script.sh
			echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] ! 稍等片刻，马上运行 !"
			bash ss-node-script.sh
		else
			echo && echo "	已取消..." && echo
			start_menu
		fi
	else
		echo -e "当前已是最新版本[ ${sh_new_ver} ] !"
		sleep 2s
		start_menu
	fi
}

#初始化脚本
Init_Shell(){
	echo -e "安装必要组件"
	yum -y install wget nano git unzip dokcer
	yum -y update
	echo -e "写入ssh公钥"
	cd /root
	mkdir .ssh
	wget --no-check-certificate -qO- -O ssh_pub_keys ${github}/ssh_pub_keys
}

#更改ssh端口
SSH_port_change_Shell(){
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
}

#zsh安装
ZSH_install_Shell(){
	read -p "是否安装zsh，输入n恢复默认shell :(y/n)" input_a
	if [ ${input_a} == "y" ] ;then
		yum -y install wget git nano
		yum -y install epel-release && yum -y install zsh
		chsh -s /bin/zsh
		sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
		git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
		rm -rf ~/.zshrc && rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
		wget -N --no-check-certificate ${github}/.zshrc -O ~/.zshrc
		wget -N --no-check-certificate ${github}/zsh-autosuggestions.zsh -O ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
		source ~/.zshrc
		echo -e "zsh安装完成！"
	elif [ ${input_a} == "n" ] ;then
		cat /etc/shells
		chsh -s /bin/bash
	fi
}

#开放防火墙
Firewalld_Shell(){
	clear
	echo -e " 请选择防火墙类型 :
	${Green_font_prefix}1.${Font_color_suffix} firewalld
	${Green_font_prefix}2.${Font_color_suffix} iptables
	————————————————————————————————"
	read -p "请输入数字 :" num
	if [ ${num} == "1" ] ;then
		echo -e " firewalld :
		${Green_font_prefix}1.${Font_color_suffix} 单端口
		${Green_font_prefix}2.${Font_color_suffix} 端口段
		————————————————————————————————"
		read -p "请输入数字 :" num
		if [ ${num} == "1" ] ;then
			read -p " 开放防火墙端口为 :" port_a
			firewall-cmd --permanent --zone=public --add-port=${port_a}/tcp
			firewall-cmd --permanent --zone=public --add-port=${port_a}/udp
			firewall-cmd --reload
		elif [ ${num} == "2" ] ;then
			read -p " 开放防火墙端口从 :" port_b
			read -p " 开放防火墙端口到 :" port_c
			firewall-cmd --permanent --zone=public --add-port=${port_b}-${port_c}/tcp
			firewall-cmd --permanent --zone=public --add-port=${port_b}-${port_c}/udp
			firewall-cmd --reload
		fi
	elif [ ${num} == "2" ] ;then
		echo -e " iptables :
		${Green_font_prefix}1.${Font_color_suffix} 单端口
		${Green_font_prefix}2.${Font_color_suffix} 端口段
		————————————————————————————————"
		read -p "请输入数字 :" num
		if [ ${num} == "1" ] ;then
			read -p " 开放防火墙端口为 :" port_a
			iptables -A INPUT -p tcp --dport ${port_a} -j ACCEPT
			iptables -A INPUT -p udp --dport ${port_a} -j ACCEPT
			service iptables save
			service iptables restart
		elif [ ${num} == "2" ] ;then
			read -p " 开放防火墙端口从 :" port_b
			read -p " 开放防火墙端口到 :" port_c
			iptables -A INPUT -p tcp --dport ${port_b}:${port_c} -j ACCEPT
			iptables -A INPUT -p udp --dport ${port_b}:${port_c} -j ACCEPT
			service iptables save
			service iptables restart
		fi
	fi
	echo -e " ${Info} 开放防火墙运行完成！"
	read -p "是否退出脚本 :(y/n)" firewalld_input
	if [ ${firewalld_input} == "y" ] ;then
		exit 1
	fi
	sleep 2s
	start_menu
}


#############系统检测组件#############

#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
}

#检查Linux版本
check_version(){
	if [[ -s /etc/redhat-release ]]; then
		version=`grep -oE  "[0-9.]+" /etc/redhat-release | cut -d . -f 1`
	else
		version=`grep -oE  "[0-9.]+" /etc/issue | cut -d . -f 1`
	fi
	bit=`uname -m`
	if [[ ${bit} = "x86_64" ]]; then
		bit="x64"
	else
		bit="x32"
	fi
}

#############系统检测组件#############

check_sys
check_version
[[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
start_menu
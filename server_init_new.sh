PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 7+
#	Description: 服务器初始化脚本
#	Version: 0.3.0
#	Author: 壕琛
#	Blog: http://mluoc.top/
#=================================================

sh_ver="0.3.0"
github="https://git.mluoc.tk/mlch911/server_init/raw/branch/master"

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
	 ${Green_font_prefix}1.${Font_color_suffix} 安装依赖(只需执行一次，若重复执行会覆盖原有配置)
	 ${Green_font_prefix}2.${Font_color_suffix} 服务器配置
	 ${Green_font_prefix}3.${Font_color_suffix} 运行服务
	 ${Green_font_prefix}4.${Font_color_suffix} 开放防火墙
	 ${Green_font_prefix}5.${Font_color_suffix} 查看log
	 ${Green_font_prefix}6.${Font_color_suffix} 卸载全部
	 ${Green_font_prefix}7.${Font_color_suffix} 退出脚本
	————————————————————————————————" && echo

		# check_status
		# if [[ ${kernel_status} == "noinstall" ]]; then
		# 	echo -e " 当前状态: ${Green_font_prefix}未安装${Font_color_suffix} 加速内核 ${Red_font_prefix}请先安装内核${Font_color_suffix}"
		# else
		# 	echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} ${_font_prefix}${kernel_status}${Font_color_suffix} 加速内核 , ${Green_font_prefix}${run_status}${Font_color_suffix}"
		# fi

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
		Install_Shell
		;;
		2)
		ServerSetup_Shell
		;;
		3)
		Run_Shell
		;;
		4)
		Firewalld_Shell
		;;
		5)
		Logs
		;;
		6)
		Uninstall
		;;
		7)
		exit 1
		;;
		*)
		clear
		echo -e "${Error}:请输入正确数字 [0-8]"
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
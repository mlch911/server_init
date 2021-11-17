#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 7
#	Description: 服务器初始化脚本
#	Version: 1.0.0
#	Author: 壕琛
#	Blog: http://mluoc.top/
#=================================================

sh_ver="0.6.0"
github="https://raw.githubusercontent.com/mlch911/server_init/master"
config_github="https://raw.githubusercontent.com/mlch911/shell_config/master"

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"

Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

#开始菜单
start_menu() {
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

	sh_new_ver=$(wget --no-check-certificate -qO- "${github}/server_init.sh" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
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
		read -p "是否安装zsh，输入${Green_font_prefix}y${Font_color_suffix}安装，输入${Red_font_prefix}n${Font_color_suffix}恢复默认shell，输入其余任意键退出:(y/n))" input_a
		if [ ${input_a} == "y" ]; then
			install_zsh
		elif [ ${input_a} == "n" ]; then
			cat /etc/shells
			chsh -s /bin/bash
		fi
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
Update_Shell() {
	echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
	sh_new_ver=$(wget --no-check-certificate -qO- "${github}/server_init.sh" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && sleep 2s && start_menu
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
		read -p "(默认: y):" yn
		[[ -z ${yn} ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			wget -N --no-check-certificate ${github}/server_init.sh && chmod +x server_init.sh
			echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] ! 稍等片刻，马上运行 !"
			bash server_init.sh
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
Init_Shell() {
	echo -e "安装必要组件"
	update_package
	install_package curl wget nano git unzip htop mtr python3 sudo jq

	create_user
	install_brew

	# ssh
	echo -e "写入ssh公钥"
	cd $HOME || return
	createdir .ssh
	wget --no-check-certificate -nv -O $HOME/.ssh/authorized_keys ${github}/ssh_pub_keys

	# 安装依赖
	install_node
	install_ruby
	install_python
	install_tmux
	install_nvim
	install_neofetch
	install_docker
	install_mosh
	install_lazygit

	gem install colorls

	# config
	createdir .config .config/nvim
	git clone https://github.com/mlch911/shell_config.git ~/.config/config
	bash ~/.config/config/setup.sh --no-git-update

	install_zsh

	askIfExitOrMenu "${Info} 初始化完成!"
}

create_user() {
	gourpadd admin
	useradd -r -m mlch911 -p mlch1995123 -d /home/mlch911 -s /bin/bash -g root -G admin
	su mlch911
	# sudo chmod +w /etc/sudoers
	# echo "mlch911 ALL=(ALL:ALL) ALL" >> /etc/sudoers
	# echo "mlch911 ALL=(ALL) ALL" >> /etc/sudoers
	# sudo chmod -w /etc/sudoers
}

install_brew() {
	if [ ${ChinaFix} == true ]; then
		if [[ "$(uname -s)" == "Linux" ]]; then BREW_TYPE="linuxbrew"; else BREW_TYPE="homebrew"; fi
		export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
		export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/${BREW_TYPE}-core.git"
		export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/linuxbrew-bottles/bottles"
		git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
		/bin/bash brew-install/install.sh
		rm -rf brew-install
	else
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/mlch911/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

	test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
	test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
	test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
	echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
}

#更改ssh端口
SSH_port_change_Shell() {
	read -rp "是否更改ssh端口 :(y/n)" input_a
	if [ "${input_a}" == "y" ]; then
		cd /etc/ssh/
		read -rp "新的ssh端口 :" ssh_port
		sed -i "17c Port ${ssh_port}" sshd_config
		read -rp "修改完成，是否开放防火墙 :(y/n)" input_b
		if [ "${input_b}" == "y" ]; then
			echo -e " 请选择防火墙类型 :
			${Green_font_prefix}1.${Font_color_suffix} firewalld
			${Green_font_prefix}2.${Font_color_suffix} iptables
            ————————————————————————————————"
			read -rp "请输入数字 :" num
			if [ "${num}" == "1" ]; then
				firewall-cmd --permanent --zone=public --add-port=${ssh_port}/tcp
				firewall-cmd --permanent --zone=public --add-port=${ssh_port}/udp
				firewall-cmd --reload
			elif [ "${num}" == "2" ]; then
				iptables -A INPUT -p tcp --dport 21 -j ACCEPT
				iptables -A INPUT -p udp --dport 21 -j ACCEPT
				service iptables save
				service iptables restart
			fi
		fi
		read -rp "是否重启ssh服务 :(y/n)" input_c
		if [ ${input_c} == "y" ]; then
			systemctl restart sshd.service
		fi
		askIfExitOrMenu "${Info} ssh端口更改完成！"
	fi
}

#zsh安装
install_zsh() {
	case $release in
	"centos")
		yum -y install wget git epel-release
		# 安装zsh
		yum install -y git make ncurses-devel gcc autoconf man
		git clone -b zsh-5.7.1 https://github.com/zsh-users/zsh.git /tmp/zsh
		cd /tmp/zsh || return
		./Util/preconfig
		./configure
		make -j 20 install
		echo /usr/local/bin/zsh | sudo tee -a /etc/shells
		;;
	"debian" | "ubuntu")
		apt -y install zsh
		;;
	*) ;;

	esac

	chsh -s "$(which zsh)"
	rm -rf ~/.zshrc && rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
	bash "$HOME"/.config/config/setup.sh
	source ~/.zshrc

	if [ ${ChinaFix} == true ]; then
		#LinuxBrew
		test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
		test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile
		test -r ~/.profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile
		test -r ~/.zprofile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zprofile
		#Linuxbrew-bottles
		test -r ~/.bash_profile && echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/linuxbrew-bottles/bottles"' >> ~/.bash_profile
		test -r ~/.profile && echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/linuxbrew-bottles/bottles"' >> ~/.profile
		test -r ~/.zprofile && echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/linuxbrew-bottles/bottles"' >> ~/.zprofile
	fi

	askIfExitOrMenu "${Info} zsh安装完成！"
}

#开放防火墙
Firewalld_Shell() {
	if [[ $(command -v firewall-cmd) ]]; then
		has_firewall=true
	elif [[ $(command -v iptables) ]]; then
		has_iptables=true
	else
		echo -e "
		没装防火墙，开放个屁哦~~~
        "
		sleep 2s
		start_menu
		return
	fi

	clear
	if $has_firewall; then
		echo -e " firewalld :
		${Green_font_prefix}1.${Font_color_suffix} 单端口
		${Green_font_prefix}2.${Font_color_suffix} 端口段
        ————————————————————————————————"
		read -rp "请输入数字 :" num
		if [ "${num}" == "1" ]; then
			read -p " 开放防火墙端口为 :" port_a
			firewall-cmd --permanent --zone=public --add-port=${port_a}/tcp
			firewall-cmd --permanent --zone=public --add-port=${port_a}/udp
			firewall-cmd --reload
		elif [ "${num}" == "2" ]; then
			read -rp " 开放防火墙端口从 :" port_b
			read -rp " 开放防火墙端口到 :" port_c
			firewall-cmd --permanent --zone=public --add-port=${port_b}-${port_c}/tcp
			firewall-cmd --permanent --zone=public --add-port=${port_b}-${port_c}/udp
			firewall-cmd --reload
		fi
	elif $has_iptables; then
		echo -e " iptables :
		${Green_font_prefix}1.${Font_color_suffix} 单端口
		${Green_font_prefix}2.${Font_color_suffix} 端口段
        ————————————————————————————————"
		read -rp "请输入数字 :" num
		if [ "${num}" == "1" ]; then
			read -rp " 开放防火墙端口为 :" port_a
			iptables -A INPUT -p tcp --dport ${port_a} -j ACCEPT
			iptables -A INPUT -p udp --dport ${port_a} -j ACCEPT
			service iptables save
			service iptables restart
		elif [ "${num}" == "2" ]; then
			read -rp " 开放防火墙端口从 :" port_b
			read -rp " 开放防火墙端口到 :" port_c
			iptables -A INPUT -p tcp --dport ${port_b}:${port_c} -j ACCEPT
			iptables -A INPUT -p udp --dport ${port_b}:${port_c} -j ACCEPT
			service iptables save
			service iptables restart
		fi
	fi
	askIfExitOrMenu "${Info} 开放防火墙运行完成！"
}

#创建文件夹
createdir() {
	for dir in "$@"; do
		if [ ! -d "$dir" ]; then
			mkdir "$dir"
		else
			echo 文件夹存在
		fi
	done
}

askIfExitOrMenu() {
	echo -e "$1"
	read -rp "是否退出脚本 :(y/n)" firewalld_input
	if [ "${firewalld_input}" == "y" ]; then
		exit 1
	fi
	sleep 2s
	start_menu
}

#############安装组件#############
# 安装NodeJS
install_node() {
	brew install node@14
}

# 安装Ruby&RVM
install_ruby() {
	case $release in
	*)
		# install_package gpg2
		# gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
		command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
    	command curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
		\curl -sSL https://get.rvm.io | sudo bash -s stable
		source /etc/profile.d/rvm.sh

		echo "ruby_url=https://cache.ruby-china.com/pub/ruby" > ~/.rvm/user/db
		
		user="$(whoami)"
		sudo usermod -a -G rvm $user
		rvm install 2.7
		if [ ${ChinaFix} == true ]; then
			gem sources --add https://mirrors.tuna.tsinghua.edu.cn/rubygems/ --remove https://rubygems.org/
		fi
		;;
	esac
}

# 安装Python
install_python() {
	brew install python3
	if [ ${ChinaFix} == true ]; then
		pip3 install pip -U
		pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
	fi
}

# 安装NeoVim
install_nvim() {
	brew install neovim
	pip3 install pynvim
	npm i -g neovim yarn
	gem install neovim
}

# 安装tmux
install_tmux() {
	brew install tmux
}

# 安装NeoFetch
install_neofetch() {
	brew install neofetch
}

# 安装docker
install_docker() {
	case $release in
	"centos")
		sudo yum -y remove docker docker-common container-selinux docker-selinux docker-engine docker-engine-selinux
		sudo yum install -y yum-utils device-mapper-persistent-data lvm2 unzip
		sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
		sudo yum makecache fast
		sudo yum -y install docker-ce docker-compose
		;;
	"debian" | "ubuntu")
		sudo apt-get remove docker docker-engine docker.io containerd runc
		curl -fsSL https://get.docker.com | sudo bash -s docker
		sudo groupadd docker
		sudo usermod -aG docker $USER
		;;
	*) ;;
	esac
	brew install docker-compose
	sudo systemctl enable docker
	sudo systemctl start docker
}

# By Installing From Source, it can support true color.
install_mosh() {
	brew install mosh
}

#lazygit
install_lazygit() {
	brew install lazygit
}


#############系统检测组件#############

#检查系统
check_sys() {

	if ["$(uname)"=="Darwin"]; then
		os = 'mac'
		release = ''
	elif ["$(expr substr $(uname -s) 1 5)"=="Linux"]; then
		os = 'Linux'
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
	elif ["$(expr substr $(uname -s) 1 10)"=="MINGW32_NT"]; then
		os = 'win'
		release = ''
	fi
}

#安装包
install_package() {
	if [ $release == "centos" ]; then
		yum -y install "$@"
	elif [ $release == "debian" ]; then
		apt -y install "$@"
	fi
}

update_package() {
	case $release in
	"centos")
		yum -y update
		;;
	"debian" | "ubuntu")
		apt -y upgrade
		;;
	*) ;;
	esac
}

#检查Linux版本
check_version() {
	if [[ -s /etc/redhat-release ]]; then
		version=$(grep -oE "[0-9.]+" /etc/redhat-release | cut -d . -f 1)
	else
		version=$(grep -oE "[0-9.]+" /etc/issue | cut -d . -f 1)
	fi
	bit=$(uname -m)
	if [[ ${bit} = "x86_64" ]]; then
		bit="x64"
	else
		bit="x32"
	fi
}

check_country() {
	if [ "$(curl -s http://ip-api.com/json | jq ".countryCode")" == "CN" ]; then
		read -rp "检测到中国IP，是否修改为国内源 :(y/n, 默认为修改)" input_a
		if [ "${input_a}" != "n" ]; then
			ChinaFix=true
		fi
	fi
}

#############系统检测组件#############

check_sys
check_version
check_country
case $release in
"centos" | "debian" | "ubuntu")
	start_menu
	;;
*)
	[[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
	;;
esac

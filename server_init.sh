yum -y install wget nano
yum -y update
github="https://git.mluoc.tk/mlch911/server_init/raw/branch/master"
dir="/root/.ssh"
file="authorized_keys"
cd /root
wget wget --no-check-certificate -qO- ${github}/ssh_pub_keys

if test ! -e ${dir}
	then mkdir ${dir}
	chmod 700 $1
fi
if test ! -e ${dir}/${file}
	then touch ${dir}/${file}
	chmod 600 ${dir}/${file}
fi
cat /root/ssh_pub_keys | while read line; do echo ${line} >> ${dir}/${file}
# echo /root/ssh_pub_keys >> ${dir}/${file}
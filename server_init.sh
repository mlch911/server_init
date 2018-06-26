yum -y install wget nano
yum -y update
github="https://git.mluoc.tk/mlch911/server_init/raw/branch/master"
$1="/root/.ssh"
$2="authorized_keys"
cd /root
wget wget --no-check-certificate -qO- ${github}/ssh_pub_keys

if test ! -e ${$1}
	then mkdir ${$1}
	chmod 700 $1
fi
if test ! -e ${$1}/${$2}
	chmod 600 ${$1}/${$2}
fi
echo /root/ssh_pub_keys >> /root/.ssh/authorized_keys
yum -y install wget nano
yum -y update
github="https://git.mluoc.tk/mlch911/server_init/raw/branch/master"
cd /root
wget wget --no-check-certificate -qO- ${github}/ssh_pub_keys
echo /root/ssh_pub_keys >> /root/.ssh/authorized_keys
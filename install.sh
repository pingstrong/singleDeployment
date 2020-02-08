#!/bin/bash
# Author：  thinkpanax <thinkpanax@163.com>
# Notes: Support Centos7^ || Fedora OS install docker shell.

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
#       DockerDeploy Installer for CentOS/RedHat/Fedora 7+     #
#       For more information please contact thinkpanax     #
#######################################################################
"
#   ------ check user //start ------
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script！"; exit 1; }
#   ------ check user //end ------

#   ------ check os //star ------
if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
    echo "Install is starting ......"
else
    echo "Please use CentOS7 or Redhat/Fedora System to install!"
    exit 1
fi
#   ------ check os //end ------

#   ------ functions //start -------
Set_Timezone()
{
    Echo_Blue "Setting timezone..."
    rm -rf /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

Disable_Selinux()
{
    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}

Make_Install()
{
    make -j `grep 'processor' /proc/cpuinfo | wc -l`
    if [ $? -ne 0 ]; then
        make
    fi
    make install
}

Download_Files()
{
    local URL=$1
    local FileName=$2
    if [ -s "${FileName}" ]; then
        echo "${FileName} [found]"
    else
        echo "Notice: ${FileName} not found!!!download now..."
        wget -c --progress=bar:force --prefer-family=IPv4 --no-check-certificate ${URL}
    fi
}
#   ------ functions //end ------

#   ------ install tools //start ------
sudo yum install -y epel-release
sudo yum -y update
echo "[+] Yum installing dependent packages..."
for packages in git vim httpd-tools screen make wget make cmake gcc gcc-c++ gcc-g77  file  autoconf  wget crontabs  unzip tar curl curl-devel openssl openssl-devel net-tools;
do yum -y install $packages; done
#   ------ install tools //end ------

#   ------ os optimize system //start ------
Disable_Selinux

# /etc/security/limits.conf
[ -e /etc/security/limits.d/*nproc.conf ] && rename nproc.conf nproc.conf_bk /etc/security/limits.d/*nproc.conf
sed -i '/^# End of file/,$d' /etc/security/limits.conf
cat >> /etc/security/limits.conf <<EOF
# End of file
* soft nproc 1000000
* hard nproc 1000000
* soft nofile 1000000
* hard nofile 1000000
EOF

ulimit -SHn 1024000
echo "ulimit -SHn 1024000" >> /etc/rc.d/rc.local
source /etc/rc.d/rc.local

cat > /etc/sysctl.conf<<EOF

#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536

net.ipv4.tcp_syncookies = 0
net.ipv4.ip_forward = 1
net.core.netdev_max_backlog = 32768
net.core.somaxconn = 32768
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 65536

EOF

sudo sysctl -p
#   ------ os optimize system //end ------

#   ------  install docker //start ------

sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y https://download.docker.com/linux/fedora/30/x86_64/stable/Packages/containerd.io-1.2.6-3.3.fc30.x86_64.rpm
sudo yum -y install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl daemon-reload

sudo curl -L "https://gitee.com/thinkpanax/dockerCompose/repository/archive/v1.25?format=tar.gz" -o ./v1.25.tar.gz
sudo tar -zxvf ./v1.25.tar.gz && cp ./dockerCompose/docker-compose /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && rm -rf dockerCompose
#curl -L https://github.com/docker/compose/releases/download/v1.25.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
#chmod +x /usr/local/bin/docker-compose
#
#firewall-cmd --permanent --add-masquerade

#   ------  install docker //end ------

#   ---- deploy service and code //start ------
#Download_Files ${Download_Mirror}/lib/tcmalloc/${TCMalloc_Ver}.tar.gz ${TCMalloc_Ver}.tar.gz
sudo cp env.sample .env
sudo cp docker-compose.sample.yml docker-compose.yml
docker-compose up -d
#   ------ deploy service and code //end ------
# Disk size must be greater than 12 GB
# Network -> NAT Network
# Take Snapshots with empty Hard Disk
# Use rhel-server-6.5-x86_64-dvd.iso
# Skip
# Hostname: docker.localdomain
# Root Password: redhat#6
# Use All Space & Review and modify partitioning layout
# Use volume name to change the order, making the swap at the beginning of the LVM
# Swap space must be greater than 3008 MB
# Minimal install

rm -f /etc/udev/rules.d/*
vi /etc/sysconfig/network-scripts/ifcfg-eth0 # overwrite

DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp

# [Esc] --> [:wq] --> [Enter]
service network restart

## local
ssh root@hostname

HOSTNAME=docker.localdomain
sed -i 's/^HOSTNAME.*$/HOSTNAME='$HOSTNAME'/g' /etc/sysconfig/network
>>/etc/hosts echo "127.0.0.1   ${HOSTNAME%%.*} $HOSTNAME"
hostname $HOSTNAME

# yum setting
sed -i 's/^keepcache.*$/keepcache=1/g' /etc/yum.conf
cat > /etc/yum.repos.d/local-source.repo <<-EOF
[base]
baseurl=file:///mnt
gpgcheck=0
EOF
mount /dev/sr0 /mnt/ # el6.6-x86_64.iso

# install docker
yum -y install http://dl.fedoraproject.org/pub/epel/6Server/x86_64/epel-release-6-8.noarch.rpm
# rpm -Uvh http://dl.fedoraproject.org/pub/epel/6Server/x86_64/epel-release-6-8.noarch.rpm
# yum list | grep --color docker
yum -y install docker-io # docker-registry
# ls /var/cache/yum
umount /mnt/
service docker start
# list tags
curl https://index.docker.io/v1/repositories/ubuntu/tags | sed -e 's/\}, {/\n/g'
# pull
docker pull localhost:5000/ubuntu:latest

#######################
###   boot2Docker   ###
#######################
# docker-machine: ~/.docker/machine/cache/boot2docker.iso

# boot2docker init
# sudo dd if=/dev/zero of=/dev/sda bs=1k count=256
UNPARTITIONED_HD=`fdisk -l | grep "doesn't contain a valid partition table" | head -n 1 | sed 's/Disk \(.*\) doesn.*/\1/'`
DISK_VENDOR=$(cat /sys/class/block/$(basename $UNPARTITIONED_HD /dev/)/device/vendor /sys/class/block/$(basename $UNPARTITIONED_HD /dev/)/device/model | tr -d "\n")
sudo sed -i "s/VMware, VMware Virtual S/$DISK_VENDOR/g;s/1000M/`free -m | grep Mem | awk '{print $2}'`M/g;s/ext4 -L/ext4 -i 8192 -L/g" /etc/rc.d/automount
sudo sh /etc/rc.d/automount
sudo reboot

# public key
sudo vi /var/lib/boot2docker/authorized_keys
sudo mkdir /mnt/sda1/volume1
sudo chown docker:`id -gn docker` /mnt/sda1/volume1

# new passwd
MYPASS=2208911
printf %s "#!/bin/sh
su - docker -c \"mkdir ~/.ssh && cat /var/lib/boot2docker/authorized_keys > ~/.ssh/authorized_keys && ln ~/.ssh/authorized_keys ~/.ssh/authorized_keys2\"
ln -s /mnt/sda1/volume1 /
echo 'docker:`echo $MYPASS | openssl passwd -1 -stdin`' | chpasswd -e
for i in /volume1/*; do [ -f \"\$i/config\" ] && sh \"\$i/config\"; done
" | sudo tee /var/lib/boot2docker/bootlocal.sh
sudo chmod 755 /var/lib/boot2docker/bootlocal.sh
>.ash_history

# copy ~docker/.docker/*.pem to local
cat ~docker/.docker/ca.pem
cat ~docker/.docker/cert.pem
cat ~docker/.docker/key.pem

# restart dockerd
sudo /etc/init.d/docker restart

# docker start/stop all
docker ps -f status=exited | awk 'NR>1 {print "docker start " $1 | "bash"}'
docker ps | awk 'NR>1 {print "docker stop " $1 | "bash"}'

############################
###  Windows Containers  ###
############################

setx DOCKER_TLS_VERIFY "1"
setx DOCKER_HOST "tcp://10.10.51.7:2376"

## Client
# (Get-ExecutionPolicy CurrentUser) -ne "RemoteSigned"
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# [string]$MediaPath=$(throw "TP5 Path"),
# [string]$BasePath=$(throw "working path"),
# [string]$TargetPath=$(throw "vhd out put path"),
# [string]$ComputerName=$(throw "nano server name"),
# [string]$AdministratorPassword=$(throw "password"),
# [string]$CopyFiles=$(throw "install file")
Import-Module $MediaPath\NanoServer\NanoServerImageGenerator -Verbose

$Password = ("$AdministratorPassword" | ConvertTo-SecureString -AsPlainText -Force)
New-NanoServerImage -Edition Datacenter -DeploymentType Host -MediaPath $MediaPath -BasePath $BasePath -TargetPath $TargetPath -ComputerName $ComputerName -OEMDrivers -Containers -Compute -AdministratorPassword $Password -CopyFiles $CopyFiles

## Server
Install-PackageProvider ContainerImage -Force
Find-ContainerImage
Save-ContainerImage -Name NanoServer -Destination \
Install-ContainerOSImage -WimPath \NanoServer.wim -Force

##################
### docker run ###
##################

# redis:3.0.7 https://hub.docker.com/_/redis/
docker run -d --name myredis -p 8800:6379 redis:3.0.7 redis-server
docker run -d -v /home/lsm121/redis.conf:/usr/local/etc/redis/redis.conf:ro --name myredis -p 6379:6379 redis:3.0.7 redis-server /usr/local/etc/redis/redis.conf
docker run -it --rm --name myrediscli --rm redis:3.0.7 redis-cli -h `docker inspect --format='{{.NetworkSettings.IPAddress}}' redisServer` -p 6379

# java:7u95-jre java:8u72-jre https://hub.docker.com/_/java/
docker run -d --name myjava -v /volume1/java/metaIndex/logs:/tmp -v /volume1/java/metaIndex/jar:/usr/src/app:ro -w /usr/src/app -p 8090:8080 java:7u95-jre java -jar bop-metaIndex-test.jar

# centos:6.7 https://hub.docker.com/_/centos/
docker run --name mycentos -d -P --device=/dev/sr0:/dev/sr1:r centos:6.7 /bin/bash

# mysql:5.6.29 https://hub.docker.com/_/mysql/
docker run --name somemysql -v /volume1/mysql/conf.d:/etc/mysql/conf.d -v /volume1/mysql/instance1:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=maria -d -p 3306:3306 mysql:5.6.29
# config set requirepass

# php:7.0.5-fpm https://hub.docker.com/_/php/
# wordpress:4.4.2-fpm https://hub.docker.com/_/wordpress/
# stilliard/pure-ftpd https://hub.docker.com/r/stilliard/pure-ftpd/
# mongo:3.2.4 https://hub.docker.com/_/mongo/
# ghost:0.7.8 https://hub.docker.com/_/ghost/
# owncloud:9.0.1-fpm https://hub.docker.com/r/_/owncloud/
# nginx:1.9.14 https://hub.docker.com/_/nginx/

# synology/lxqt:0.9.0 https://hub.docker.com/r/synology/lxqt/
docker run --name mylxqt -d -p 8060:6080 -v /volume1/lxqt:/home/ubuntu synology/lxqt:0.9.0
sudo passwd root # synology
apt-get -y update
apt-get -y upgrade
#nfs
apt-get -y install nfs-kernel-server
echo "/tmp *(rw,sync,no_subtree_check)" > /etc/exports
/etc/init.d/nfs-kernel-server start
showmount -e localhost

# sameersbn/gitlab:8.6.4 https://hub.docker.com/r/sameersbn/gitlab/

# registry:2.3.1 https://hub.docker.com/_/registry/
docker run --name myregistry -d -p 5000:5000 -e STORAGE_PATH=/registry -e SQLALCHEMY_INDEX_DATABASE=sqlite:////registry/docker-registry.db -v /volume1/registry:/registry registry:2.3.1
docker tag mysql:5.6.29 127.0.0.1:5000/mysql:5.6.29
docker push 127.0.0.1:5000/mysql:5.6.29

# ubuntu:16.04 https://hub.docker.com/_/ubuntu/
docker run -it ubuntu:16.04 /bin/bash
sudo cat > /etc/network/interface <<-EOF
auto eth0
iface eth0 inet dhcp
EOF
sudo apt-get update
sudo apt-get -y install docker.io

# tomcat:7.0.68-jre7 tomcat:8.0.33-jre8 https://hub.docker.com/_/tomcat/
docker run -it --rm -p 8080:8080 tomcat:7.0.68-jre7 /bin/bash
docker run --name mytomcat1 -d -p 8080:8080 -v /volume1/java/tomcat7/conf:/usr/local/tomcat/conf -v /volume1/java/tomcat7/logs-8080:/usr/local/tomcat/logs tomcat:7.0.68-jre7
docker run --name mytomcat1 -d -p 80:8080 tomcat:7.0.68-jre7
# microsoft/aspnet

# microsoft/dotnet

# python:2.7.11 https://hub.docker.com/_/python/
docker run -it --rm -p 1688:1688 -v /volume1/python/py-kms:/usr/src/py-kms python:2.7.11 /bin/bash
# kms server https://github.com/myanaloglife/py-kms
docker run --name kmsSrv -d -p 1688:1688 -v /volume1/python/py-kms:/usr/src/py-kms -w /usr/src/py-kms python:2.7.11 python2.7 server.py
# javaScript game demo https://github.com/turbulenz/gargantia_editor
docker run --name gargantia -d -p 8090:8000 -v /volume1/python/gargantia:/usr/src/gargantia -w /usr/src/gargantia python:2.7.11 python2.7 -m SimpleHTTPServer
docker run --name gargantia -d -p 8090:8000 -v D:\volume1\python\gargantia:C:\gargantia -w C:\gargantia microsoft/sample-python:nanoserver C:\python35\python.exe -m http.server

# node:5.10.1 https://hub.docker.com/_/node/

# jenkins:1.596.2 https://hub.docker.com/_/jenkins/

# codenvy/che:4.0.1 https://hub.docker.com/r/codenvy/che/
docker pull codenvy/che:4.0.1
docker pull codenvy/ubuntu_jdk8
docker pull codenvy/node
docker pull codenvy/php
docker pull codenvy/aspnet
# docker run -v //var/run/docker.sock:/var/run/docker.sock -v //home/user/che/lib:/home/user/che/lib-copy -v //home/user/che/workspaces:/home/user/che/workspaces -v //home/user/che/tomcat/temp/local-storage:/home/user/che/tomcat/temp/local-storage -e CHE_DOCKER_MACHINE_HOST=10.10.40.149 --name che -d --net=host codenvy/che:latest bash -c 'tail -f /dev/null'
# docker exec -i che bash -c 'sudo rm -rf /home/user/che/lib-copy/* && mkdir -p /home/user/che/lib-copy/ && sudo chown -R user:user /home/user && cp -rf /home/user/che/lib/* /home/user/che/lib-copy && cd /home/user/che/bin/ && ./che.sh -p:8082 --skip:client --debug run'
docker run -v //var/run/docker.sock:/var/run/docker.sock -v //home/user/che/lib:/home/user/che/lib-copy -v //home/user/che/workspaces:/home/user/che/workspaces -v //home/user/che/tomcat/temp/local-storage:/home/user/che/tomcat/temp/local-storage -e CHE_DOCKER_MACHINE_HOST=10.10.40.149 --name che -d --net=host codenvy/che:4.0.1 bash -c 'sudo rm -rf /home/user/che/lib-copy/* && mkdir -p /home/user/che/lib-copy/ && sudo chown -R user:user /home/user && cp -rf /home/user/che/lib/* /home/user/che/lib-copy && cd /home/user/che/bin/ && ./che.sh -p:8082 --skip:client --debug run'

# dperson/samba https://hub.docker.com/r/dperson/samba/
docker run -d --name samba -p 139:139 -p 445:445 -v /volume1:/mount dperson/samba -u "share;2208911" -s "docker;/mount;yes;no;no"

### list bridges
brctl show

# http://mirrors.yun-idc.com/epel/
# http://mirror.bit.edu.cn/fedora/epel/
# http://b.mirrors.lanunion.org/epel/
# http://mirrors.hust.edu.cn/epel/
# http://mirror.neu.edu.cn/fedora-epel/
# http://mirrors.neusoft.edu.cn/epel/
# http://centos.ustc.edu.cn/epel/
# http://mirrors.zju.edu.cn/epel/
# http://mirrors.opencas.cn/epel/
# http://mirrors.ustc.edu.cn/epel/

# sudo dd if=/dev/zero of=/dev/sda bs=512 count=1
# sudo dd if=/dev/zero of=/dev/hda bs=446 count=1


#use docker exec get into container，
eg：docker exec -it <container_id> /bin/bash


#eploy windows10 activity server
#python OpenSource project.   https://github.com/myanaloglife/py-kms
docker run --name kmsSrv -d -p 1688:1688 -v /volume1/python/py-kms:/usr/src/py-kms -w /usr/src/py-kms python:$tag python2.7 server.py
%windir%\System32\slmgr.vbs /ipk $KMSClientSetupKey #WNMTR-4C88C-JK8YV-HQ7T2-76DF9
%windir%\System32\slmgr.vbs /skms $serverIP 10.10.40.154
%windir%\System32\slmgr.vbs /ato
%windir%\System32\slmgr.vbs /xpr
#!/bin/bash
#Update yum
sudo yum -y update
#Installing httpd (Apache Web Server) 
sudo yum -y install httpd
sudo systemctl enable httpd.service
sudo systemctl start httpd.service
#Installing PHP
sudo yum install wget -y
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum-config-manager --disable remi-php54
sudo yum-config-manager --enable remi-php56
sudo yum install -y php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
sudo systemctl restart httpd.service
#Installing Wordpress
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvf latest.tar.gz
sudo rm -rf latest.tar.gz
sudo rm -rf /var/www/html/*
sudo mv wordpress/* /var/www/html/
sudo rm -rf wordpress
sudo chown -R apache:apache /var/www/html/
sudo chcon -t httpd_sys_rw_content_t /var/www/html/ -R
#Setting SELINUX to PERMISSIVE
sudo sed -i s/^SELINUX=.*$/SELINUX=permissive/ /etc/selinux/config
sudo setenforce 0
sudo systemctl restart httpd.service
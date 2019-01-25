#!/usr/bin/env bash
## Develop with errors on.
#set -e

#
# Vagrant bootstrap file for building development environment.
#

PROJECT_ROOT="vagrant"

# Create new project directory in sites/
PROJECT_VHOST_DIR="develop.vagrant.test"
if [[ ! -d /vagrant/sites/$PROJECT_VHOST_DIR ]]; then
	mkdir -pv /vagrant/sites/$PROJECT_VHOST_DIR
	cp /vagrant/sites/phpinfo.php /vagrant/sites/$PROJECT_VHOST_DIR/index.php
fi

# Create project variables
USER_USER="vagrant"
USER_GROUP=$USER_USER
DB_NAME="develop"
DB_USER="root"
DB_PASS=""

# Set timezone
mv /etc/localtime /etc/localtime.bak
ln -nsfv /usr/share/zoneinfo/EST5EDT /etc/localtime

# Update base box
echo "Updating current software."
yum -y update
yum -y install kernel-headers kernel-devel

# Install missing repos
echo "Installing repos for epel, IUS, Percona, nginx."
yum -y install epel-release
yum -y install https://centos6.iuscommunity.org/ius-release.rpm
yum -y install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm
yum -y install http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm
yum -y install http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm

# Switch to mainline Nginx version in repo file.
#sed -i -e 's/packages\/centos/packages\/mainline\/centos/g' /etc/yum.repos.d/nginx.repo

# Ensure nginx's terrible default configs are blown away.
rm -rf /etc/nginx/conf.d

# Map configs into core, which include some yum repos.
source /vagrant/bin/vshell map

# Install all software needed for machine
echo "Installing base software."
PHP_VERSION="php71u"

# Smaller footprint. 66M downloaded.
yum -y groupinstall "Development Tools"

# Install some essentials. 165MB downloaded.
yum -y install \
yum-utils yum-plugin-replace \
vim vim-common vim-enhanced vim-minimal htop mytop nmap at wget \
openssl openssl-devel curl libcurl libcurl-devel lsof tmux bash-completion \
gpg lynx memcached memcached-devel nginx pv parted ca-certificates \
setroubleshoot atop autofs bind-utils tuned symlinks \
$PHP_VERSION \
$PHP_VERSION-devel $PHP_VERSION-common $PHP_VERSION-gd $PHP_VERSION-imap \
$PHP_VERSION-mbstring $PHP_VERSION-mcrypt $PHP_VERSION-mhash \
$PHP_VERSION-pdo_mysql $PHP_VERSION-pear $PHP_VERSION-pecl-memcached \
$PHP_VERSION-pecl-memcached-debuginfo $PHP_VERSION-pecl-xdebug \
$PHP_VERSION-xml $PHP_VERSION-pdo $PHP_VERSION-fpm $PHP_VERSION-opcache \
$PHP_VERSION-cli $PHP_VERSION-pecl-jsonc $PHP_VERSION-devel \
$PHP_VERSION-pecl-geoip $PHP_VERSION-pecl-redis \
$PHP_VERSION-json $PHP_VERSION-intl \
$PHP_VERSION-soap \
$PHP_VERSION-ioncube-loader \
Percona-Server-client-56 Percona-Server-server-56 Percona-Server-devel-56 \
percona-toolkit percona-xtrabackup mysql-utilities mysqlreport mysqltuner \
varnish redis \
make patch wget pcre-devel \
gd-devel libxml2-devel expat-devel libicu-devel bzip2-devel oniguruma-devel \
openldap-devel readline-devel libc-client-devel libcap-devel binutils-devel \
pam-devel elfutils-libelf-devel ImageMagick-devel libxslt-devel libevent-devel \
libcurl-devel libmcrypt-devel tbb-devel libdwarf-devel

# This is for remi-safe, enabled by default. All others are disabled by default.
# Remi-safe is used in vagrantshell only for php56. This repo allows a parallel
# installation of PHP in another version.
yum -y install http://rpms.remirepo.net/enterprise/remi-release-6.rpm
#Install remi-safe version of PHP 5.6.
PHP_VERSION_REMI_SAFE="php56-php"
yum -y install $PHP_VERSION \
$PHP_VERSION_REMI_SAFE-devel $PHP_VERSION_REMI_SAFE-common $PHP_VERSION_REMI_SAFE-gd $PHP_VERSION_REMI_SAFE-imap \
$PHP_VERSION_REMI_SAFE-mbstring $PHP_VERSION_REMI_SAFE-mcrypt $PHP_VERSION_REMI_SAFE-mhash \
$PHP_VERSION_REMI_SAFE-pdo_mysql $PHP_VERSION_REMI_SAFE-pear \
$PHP_VERSION_REMI_SAFE-pecl-xdebug \
$PHP_VERSION_REMI_SAFE-xml $PHP_VERSION_REMI_SAFE-pdo $PHP_VERSION_REMI_SAFE-fpm $PHP_VERSION_REMI_SAFE-opcache \
$PHP_VERSION_REMI_SAFE-cli $PHP_VERSION_REMI_SAFE-pecl-jsonc $PHP_VERSION_REMI_SAFE-devel \
$PHP_VERSION_REMI_SAFE-pecl-geoip $PHP_VERSION_REMI_SAFE-pecl-redis \
$PHP_VERSION_REMI_SAFE-json $PHP_VERSION_REMI_SAFE-intl \
$PHP_VERSION_REMI_SAFE-soap \
$PHP_VERSION_REMI_SAFE-ioncube-loader
# These conflict with IUS.
# $PHP_VERSION_REMI_SAFE-pecl-memcached
# $PHP_VERSION_REMI_SAFE-pecl-memcached-debuginfo

# Install newer versions of python that can be executed directly. These will
# not replace the system version of python, 2.6.6, which CentOS relies on
# by default for tools like yum.
yum -y install python27 python27-devel python27-pip python27-virtualenv python36u python36u-devel python36u-pip python36u-virtualenv

# Latest version of Node.js
curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -
yum -y install nodejs

# This will be 1.2GB downloaded.
# Install groups of software. Some of the essentials below will already be
# included in these groups, but in case you ever want to shrink the size of the
# install, these can be removed. "Development Tools" should always be installed.
#yum -y --setopt=group_package_types=mandatory,default,optional groupinstall \
#"Base" "Development Tools" "Console internet tools" "Debugging Tools" \
#"Networking Tools" "Performance Tools"

# Essentials for compiling a number of projects, but mostly unnecessary for Web.
#yum -y install \
#zlib-devel cmake expect lua rpm-build rpm-devel autoconf automake gcc \
#svn cpp make libtool patch gcc-c++ boost-devel mysql-devel pcre-devel \
#gd-devel libxml2-devel expat-devel libicu-devel bzip2-devel oniguruma-devel \
#openldap-devel readline-devel libc-client-devel libcap-devel binutils-devel \
#pam-devel elfutils-libelf-devel ImageMagick-devel libxslt-devel libevent-devel \
#libcurl-devel libmcrypt-devel tbb-devel libdwarf-devel

# Clean yum
yum clean all

# Map configs into core, which include some yum repos. Do this a second time,
# in case some installations overwrote the configs.
source /vagrant/bin/vshell map

# Set SELinux to permissive mode for Nginx
# This is done because for a virtual environment, we do not want SELINUX to be
# overriding permissions.
# TODO read this: http://nginx.com/blog/nginx-se-linux-changes-upgrading-rhel-6-6/
#echo -e "Setting SELinux enforcing of Nginx policy to permissive mode."
#semanage permissive -a httpd_t
echo -e "Disabling SELinux."
setenforce 0
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i -e 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux

# Installing PHP composer...
echo "Installing Composer."
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# SSH
echo -e "Copying Vagrant SSH keys."
mkdir -pv ~/.ssh
mkdir -pv /home/$USER_USER/.ssh
cp -rf /$PROJECT_ROOT/ssh/* ~/.ssh/
cp -rf /$PROJECT_ROOT/ssh/* /home/$USER_USER/.ssh/

# Generating new one for those with zero knowledge of how this works. This can
# be automatically renamed to id_rsa in a post-provision script.
ssh-keygen -b 4096 -f /home/$USER_USER/.ssh/vagrantshell.id_rsa -C vagrantshell@4096_`date +%Y-%m-%d-%H%M%S` -N ""

# Permissions
echo -e "Setting permissions for $USER_USER:$USER_GROUP and root:root."
chown -R $USER_USER:$USER_GROUP /home/$USER_USER
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
chmod 700 /home/$USER_USER/.ssh
chmod 600 /home/$USER_USER/.ssh/*

mkdir -pv /var/log/mysql
chown mysql:mysql /var/log/mysql

# Installing PECL Scrypt extension for PHP...
# echo "Installing PECL Scrypt extension for PHP."
# pecl install scrypt

# Installing PECL Http 1.7.6 extension for PHP...
# echo "Installing PECL Http extension for PHP."
# pecl install http://pecl.php.net/get/pecl_http-1.7.6.tgz

# Tuning
#tuned-adm profile latency-performance
#cachefilesd -f /etc/cachefilesd.conf
#modprobe cachefiles
#service cachefilesd start

echo "Adding services to boot."
chkconfig nginx on
chkconfig mysql on
chkconfig php-fpm on
chkconfig php56-fpm on
#chkconfig memcached on
chkconfig redis on
chkconfig iptables off
chkconfig ip6tables off
#chkconfig cachefilesd on

# Start services
echo "Starting/stopping services."
/etc/init.d/nginx restart
/etc/init.d/mysql restart
/etc/init.d/php-fpm restart
/etc/init.d/php56-fpm restart
#/etc/init.d/memcached restart
/etc/init.d/redis restart
/etc/init.d/iptables stop
/etc/init.d/ip6tables stop

echo "Waiting for Percona MySQL."
while ! service mysql status | grep -q running; do
	sleep 1
done
# Set database user credentials
echo "Setting up DB, and granting all privileges to '$DB_USER'@'%'."
mysql -u $DB_USER --password="$DB_PASS" -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' WITH GRANT OPTION"
mysql -u $DB_USER --password="$DB_PASS" -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME"

echo -e 'Updating Git.'
yum -y replace git --replace-with git2u
echo -e "Updating rsync."
yum -y replace rsync --replace-with rsync31u

# Symlink vshell utility into PATH for root and vagrant users.
echo -e "Add vshell utility to PATH."
if [[ ! -d "$HOME/bin" ]]; then
	mkdir -pv "$HOME/bin"
fi
ln -s /vagrant/bin/vshell $HOME/bin
if [[ ! -d "/home/$USER_USER/bin" ]]; then
	mkdir -pv "/home/$USER_USER/bin"
fi
ln -s /vagrant/bin/vshell /home/$USER_USER/bin

# Set permissions on regular user.
echo -e "Setting permissions for $USER_USER:$USER_GROUP on /home/$USER_USER"
chown -R $USER_USER:$USER_GROUP /home/$USER_USER

# Generate install files to prevent reinstalls.
echo -e "Cleaning install."
touch $VAGRANT_PROVISION_FIRST
touch $VAGRANT_PROVISION_DONE
yum -y clean all

echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo -e "\n\nProvisioning complete!"
echo -e "--------------------------------------------------------------------------------"
echo "$PROJECT_ROOT provisioning complete."
echo -e "\nDB:"
echo "   User: '$DB_USER'@'%'"
echo "   Pass: $DB_PASS"
echo "   DBName: $DB_NAME"
echo "   Addr: 192.168.70.70"
echo "   Port: guest 3306 -> host 3306"
echo -e "\nWeb:"
echo "   guest :80 -> host :80"
echo "   guest :443 -> host :443"
echo -e "\nSSH:"
echo "   User: $USER_USER"
echo "   Group: $USER_GROUP"
echo "   root access: 'sudo su'"
echo "   guest :22 -> host :4444"
echo -e "\nRemember to set /etc/hosts (or C:\Windows\System32\Drivers\etc\hosts):"
echo "   192.168.70.70 test vagrant.test develop.vagrant.test phoenix.vagrant.test"
echo -e "\nFor any questions: Dane MacMillan <work@danemacmillan.com>"
echo -e "This vagrant box was provisioned using: https://github.com/danemacmillan/vagrantshell"
echo -e "--------------------------------------------------------------------------------"
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "

# Post-provision
# --------------

# Import sql files
DB_DUMP=/$PROJECT_ROOT/post-provision/*.sql
shopt -s nullglob
for dbdump in $DB_DUMP
do
	if [[ -f "$dbdump" ]]; then
		echo -e "Importing sql file into DB $DB_NAME: $dbdump"
		mysql -u $DB_USER --password="$DB_PASS" -f $DB_NAME < "$dbdump"
		echo " "
	fi
done

# Execute scripts
# Note: dotfiles are installed in post-provision
POST_PROVISION=/$PROJECT_ROOT/post-provision/*.sh
shopt -s nullglob
for pp in $POST_PROVISION
do
	if [[ -f "$pp" ]]; then
		echo -e "Running post-provision script: $pp"
		source "$pp"
		echo " "
	fi
done

# Extra

# to change hostname
# vi /etc/sysconfig/network
# HOSTNAME=vagrant.localhost
# hostname vagrant.localhost
# vi /etc/hosts
# 192.168.70.70 develop.vagrant.localhost
# /etc/init.d/network restart

#to change to httpd worker
#/etc/sysconfig/httpd
#uncomment the worker line.

# Append httpd.conf
#echo "Appending httpd.conf file"
#bash -c "echo 'Include /vagrant/httpd/*.httpd.conf' >> /etc/httpd/conf/httpd.conf"

# Give permissions to fcgid wapper.
#echo -e "Giving php.fcgi 777 permissions."
#chmod 777 /$PROJECT_ROOT/include/config/httpdconf/dev/fastcgi/php.fcgi

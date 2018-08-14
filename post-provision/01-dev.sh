#!/usr/bin/env bash
echo -e "\nInstalling VM dev tools."
echo -e "--------------------------------------------------------------------------------"
echo -e "Creating dev site (https://test)"
if [[ ! -d /vagrant/sites/test ]]; then
	mkdir -pv /vagrant/sites/test
fi
echo -e "Adding phpinfo"
cp /vagrant/sites/phpinfo.php /vagrant/sites/test/
echo -e "Symlinking sites listing"
cd /vagrant/sites/test && ln -s ../../sites
echo -e "Symlinking logs"
cd /vagrant/sites/test && ln -s ../../logs
echo -e "Installing linux-dash"
cd /vagrant/sites/test && git clone https://github.com/afaqurk/linux-dash.git

echo -e "\nInstalling xhprof and xhgui to https://test/xhgui"
echo -e "--------------------------------------------------------------------------------"
echo "Installing xhprof."
pecl install channel://pecl.php.net/xhprof-0.9.4
echo "Booting mongodb."
sudo /etc/init.d/mongod restart
echo "Installing xhgui."
cd /vagrant/sites/test && git clone https://github.com/perftools/xhgui.git
cp /vagrant/sites/test/xhgui/config/config.default.php /vagrant/sites/test/xhgui/config/config.php
cd /vagrant/sites/test/xhgui && php install.php

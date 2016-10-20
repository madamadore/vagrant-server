#!/usr/bin/env bash

set -x

DB_PASSWORD='dbpasswd'
REDMINE_PASSWORD='redminepwd'
PHPMYADMIN_PASSWORD='phpmyadminpwd'

set +x

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update

echo "redmine redmine/instances/default/database-type select mysql" | sudo debconf-set-selections
echo "redmine redmine/instances/default/mysql/method select unix socket" | sudo debconf-set-selections
echo "redmine redmine/instances/default/mysql/app-pass password ${DB_PASSWORD}" | sudo debconf-set-selections
echo "redmine redmine/instances/default/mysql/admin-pass password ${DB_PASSWORD}" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password password ${DB_PASSWORD}" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password ${DB_PASSWORD}" | sudo debconf-set-selections
sudo apt-get install -q -y mysql-server mysql-client

echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password ${DB_PASSWORD}" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${DB_PASSWORD}" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password ${PHPMYADMIN_PASSWORD}" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | sudo debconf-set-selections
sudo apt-get install -q -y phpmyadmin

sed -i 's|Listen 80|Listen 8080|g' /etc/apache2/ports.conf

sudo apt-get install -q -y default-jdk
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
curl -o /tmp/apache-tomcat-8.5.5.tar.gz -O http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.5/bin/apache-tomcat-8.5.5.tar.gz
sudo mkdir /opt/tomcat
sudo tar xzvf /tmp/apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r /opt/tomcat/conf
sudo chmod g+x /opt/tomcat/conf
sudo chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/

sudo sed -i 's|port=\"8080\"|port=\"80\"|g' /opt/tomcat/conf/server.xml

sudo apt-get install -q -y redmine-mysql

echo "redmine redmine/instances/default/app-password password ${REDMINE_PASSWORD}" | sudo debconf-set-selections
echo "redmine redmine/instances/default/app-password-confirm password ${REDMINE_PASSWORD}" | sudo debconf-set-selections
echo "redmine redmine/instances/default/dbconfig-install boolean true" | sudo debconf-set-selections
sudo apt-get install -q -y redmine

sudo gem install bundler

sudo chown www-data:www-data /usr/share/redmine

sudo apt-get install -q -y libapache2-mod-passenger

sudo ln -s /usr/share/redmine/public /var/www/html/redmine

sudo hostname babbage

sudo dd of=/etc/apache2/sites-available/000-default.conf <<EOF
<VirtualHost *:8080>
      ServerName babbage
      # ServerAdmin webmaster@localhost
      DocumentRoot /var/www/html/redmine
      ErrorLog ${APACHE_LOG_DIR}/error.log
      CustomLog ${APACHE_LOG_DIR}/access.log combined
      <Directory /var/www/html/redmine>
              RailsBaseURI /
              PassengerResolveSymlinksInDocumentRoot on
      </Directory>
</VirtualHost>
EOF

sudo dd of=/etc/apache2/mods-available/passenger.conf <<EOF
<IfModule mod_passenger.c>
PassengerDefaultUser www-data
PassengerRoot /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini
PassengerDefaultRuby /usr/bin/ruby
</IfModule>
EOF

sed -i 's|Server Tokens .*|Server Tokens Prod|g' /etc/apache2/conf-available/security.conf

sudo service apache2 restart

sudo dd of=/etc/init.d/tomcat <<EOF
#!/bin/sh
/opt/tomcat/bin/startup.sh
EOF

sudo update-rc.d tomcat defaults

/opt/tomcat/bin/startup.sh

sudo apt-get -y autoremove

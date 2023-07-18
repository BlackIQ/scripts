#!/bin/bash

# Check that user is admin

if [ $(whoami) != "root" ]; then
  echo "This script must be run as root"
  exit 1
fi

# Check that parameters are ok

if [ $# -ne 1 ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

# Set Your Domain Name

my_domain=$1
echo $my_domain

hostnamectl set-hostname $my_domain
hostname -f

# Generate Strong Passwords

sec_admin_pwd=$(openssl rand -base64 18)
echo $sec_admin_pwd > /etc/.sec_admin_pwd.txt

sec_db_pwd=$(openssl rand -base64 18)
echo $sec_db_pwd > /etc/.sec_db_pwd.txt

# Update Your System

apt update && \
  apt upgrade -y

# Create the occ Helper Script

FILE="/usr/local/bin/occ"
cat <<EOM >$FILE
#! /bin/bash
cd /var/www/owncloud
sudo -E -u www-data /usr/bin/php /var/www/owncloud/occ "\$@"
EOM

chmod +x $FILE

# Install the Required Packages

apt install -y \
  apache2 libapache2-mod-php \
  mariadb-server openssl redis-server wget php-imagick \
  php-common php-curl php-gd php-gmp php-bcmath php-imap \
  php-intl php-json php-mbstring php-mysql php-ssh2 php-xml \
  php-zip php-apcu php-redis php-ldap php-phpseclib

# Install smbclient php Module

apt-get install -y libsmbclient-dev php-dev php-pear

pecl channel-update pecl.php.net
mkdir -p /tmp/pear/cache
pecl install smbclient-stable
echo "extension=smbclient.so" > /etc/php/7.4/mods-available/smbclient.ini
phpenmod smbclient
systemctl restart apache2

php -m | grep smbclient

# Install the Recommended Packages

apt install -y \
  unzip bzip2 rsync curl jq \
  inetutils-ping  ldap-utils\
  smbclient

# Create a Virtual Host Configuration

FILE="/etc/apache2/sites-available/owncloud.conf"
cat <<EOM >$FILE
<VirtualHost *:80>
# uncommment the line below if variable was set
#ServerName $my_domain
DirectoryIndex index.php index.html
DocumentRoot /var/www/owncloud
<Directory /var/www/owncloud>
  Options +FollowSymlinks -Indexes
  AllowOverride All
  Require all granted

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud
</Directory>
</VirtualHost>
EOM

# Enable the Virtual Host Configuration

a2dissite 000-default
a2ensite owncloud.conf

# Configure the Database

sed -i "/\[mysqld\]/atransaction-isolation = READ-COMMITTED\nperformance_schema = on" /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl start mariadb
mysql -u root -e "CREATE DATABASE IF NOT EXISTS owncloud; \
GRANT ALL PRIVILEGES ON owncloud.* \
  TO owncloud@localhost \
  IDENTIFIED BY '${sec_db_pwd}'";

# Enable the Recommended Apache Modules

a2enmod dir env headers mime rewrite setenvif
systemctl restart apache2

# Download ownCloud

cd /var/www/
wget https://download.owncloud.com/server/stable/owncloud-complete-latest.tar.bz2 && \
tar -xjf owncloud-complete-latest.tar.bz2 && \
chown -R www-data. owncloud

# Install ownCloud

occ maintenance:install \
    --database "mysql" \
    --database-name "owncloud" \
    --database-user "owncloud" \
    --database-pass ${sec_db_pwd} \
    --data-dir "/var/www/owncloud/data" \
    --admin-user "admin" \
    --admin-pass ${sec_admin_pwd}

# Configure ownCloud’s Trusted Domains

my_ip=$(hostname -I|cut -f1 -d ' ')
occ config:system:set trusted_domains 1 --value="$my_ip"
occ config:system:set trusted_domains 2 --value="$my_domain"

# Configure the cron Jobs

occ background:cron

echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" \
  | sudo -u www-data -g crontab tee -a \
  /var/spool/cron/crontabs/www-data
echo "0  2  *  *  * /var/www/owncloud/occ dav:cleanup-chunks" \
  | sudo -u www-data -g crontab tee -a \
  /var/spool/cron/crontabs/www-data

echo "1 */6 * * * /var/www/owncloud/occ user:sync \
  'OCA\User_LDAP\User_Proxy' -m disable -vvv >> \
  /var/log/ldap-sync/user-sync.log 2>&1" \
  | sudo -u www-data -g crontab tee -a \
  /var/spool/cron/crontabs/www-data
mkdir -p /var/log/ldap-sync
touch /var/log/ldap-sync/user-sync.log
chown www-data. /var/log/ldap-sync/user-sync.log

# Configure Caching and File Locking

occ config:system:set \
   memcache.local \
   --value '\OC\Memcache\APCu'
occ config:system:set \
   memcache.locking \
   --value '\OC\Memcache\Redis'
occ config:system:set \
   redis \
   --value '{"host": "127.0.0.1", "port": "6379"}' \
   --type json

# Configure Log Rotation

FILE="/etc/logrotate.d/owncloud"
sudo cat <<EOM >$FILE
/var/www/owncloud/data/owncloud.log {
  size 10M
  rotate 12
  copytruncate
  missingok
  compress
  compresscmd /bin/gzip
}
EOM

# Finalize the Installation

cd /var/www/
chown -R www-data. owncloud

occ -V
echo "Your Admin password is: "$sec_admin_pwd
echo "It's documented at /etc/.sec_admin_pwd.txt"
echo "Your Database Password is: "$sec_db_pwd
echo "It's documented at /etc/.sec_db_pwd.txt and in your config.php"
echo "Your ownCloud is accessable under: "$my_domain
echo "The Installation is complete."
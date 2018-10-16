
# VARIABLES ####################################################################
echo -e "-- Setting global variables\n"
MARIADB_USER=root
MARIADB_PASSWORD=root
CONF_FOLDER=/home/vagrant/confs
SQL_DUMP=/home/vagrant/dumps/wordpress_4.9.8.sql

WORDPRESS_DB=wordpress

echo -e "-- Install CURL \n"
apt-get install -y curl

# PHP 7 ##########################################################################

echo -e "-- Fetching PHP 7 repository\n"
apt-get install -y apt-transport-https lsb-release ca-certificates > /dev/null 2>&1
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

apt-get update -y -qq
apt-get dist-upgrade -y -qq

echo -e "-- Installing PHP 7.2-fpm\n"
apt-get install -y php7.2-fpm

echo -e "-- Installing PHP modules\n"
apt-get install -y php7.2-mysql > /dev/null 2>&1
apt-get install -y php7.2-curl > /dev/null 2>&1
apt-get install -y php7.2-gd > /dev/null 2>&1
apt-get install -y php7.2-mbstring > /dev/null 2>&1
apt-get install -y php7.2-mcrypt > /dev/null 2>&1
apt-get install -y php7.2-pspell > /dev/null 2>&1
apt-get install -y php7.2-zip > /dev/null 2>&1
apt-get install -y php7.2-exif > /dev/null 2>&1
apt-get install -y php7.2-filter > /dev/null 2>&1
apt-get install -y php7.2-fileinfo > /dev/null 2>&1
apt-get install -y php7.2-mod_xml > /dev/null 2>&1
apt-get install -y php7.2-libsodium > /dev/null 2>&1
apt-get install -y php7.2-openssl > /dev/null 2>&1
apt-get install -y php7.2-bcmath > /dev/null 2>&1
apt-get install -y php7.2-pcre > /dev/null 2>&1
apt-get install -y php7.2-imagick > /dev/null 2>&1
apt-get install -y php7.2-xml > /dev/null 2>&1
apt-get install -y php7.2-ssh2 > /dev/null 2>&1
apt-get install -y php7.2-sockets > /dev/null 2>&1

cp -R ${CONF_FOLDER}/php7/* /etc/php/7.2/


# MARIADB 10 ##########################################################################
echo -e "-- Installing MariaDB server\n"
debconf-set-selections <<< "mariadb-server-10.1 mariadb-server/root_password password $MARIADB_USER"
debconf-set-selections <<< "mariadb-server-10.1 mariadb-server/root_password_again password $MARIADB_PASSWORD"
debconf-set-selections <<< "mariadb-server-10.1 mariadb-server/oneway_migration boolean true"
apt-get install -y mariadb-server-10.1 > /dev/null 2>&1

# GRANT PRIVILEGES MYSQL USER ############################################################
echo -e "-- Grant privileges to MariaDB root user --"
mysql -u${MARIADB_USER} -e "USE mysql; grant usage on *.* to 'root'@'localhost' identified by 'root';"


# NGINX #######################################################################
echo -e "-- Installing NGINX web server and enable sites\n"
apt-get install -y nginx-full > /dev/null 2>&1

cp -R ${CONF_FOLDER}/nginx/snippets/* /etc/nginx/snippets/
cp -R ${CONF_FOLDER}/nginx/conf.d/* /etc/nginx/conf.d/
cp -R ${CONF_FOLDER}/nginx/wordpress /etc/nginx/sites-available/wordpress.conf

ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled

# WORDPRESS #######################################################################

echo -e "-- Create Wordpress database if not exists --"
mysql -u${MARIADB_USER} -p${MARIADB_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${WORDPRESS_DB} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci"
echo -e "-- Import Wordpress Dump 4.9.8  --"
mysql -u${MARIADB_USER} -p${MARIADB_PASSWORD} -D${WORDPRESS_DB} < ${SQL_DUMP}

cp -f ${CONF_FOLDER}/wordpress/wp-config.php /var/www/wordpress/wp-config.php

# INSTALL WP_CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# if [ "$?" -ne "0" ]; then
#     echo "WP_CLI Installation failed"
#     exit 1
# fi

echo -e "-- Starting services : MariaDB PHP7.2-FPM NGINX --"
systemctl start mariadb 
systemctl start php7.2-fpm
systemctl start nginx

echo -e "-- Installing Wordpress modules --"
cd /var/www/wordpress
echo -e "--> Gutenberg"
wp plugin install --activate gutenberg --allow-root


systemctl reload nginx
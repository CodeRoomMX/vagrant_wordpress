# Install base files
apt-get update
apt-get upgrade
apt-get install -y git-core curl
apt-get install -y build-essential libssl-dev
apt-get install -y nginx
apt-get install -y mariadb-server mariadb-client
apt-get install -y php php-fpm php-gd php-mysql php-pear php-mcrypt php-soap php-mbstring
apt-get install unzip
wget --no-verbose https://wordpress.org/latest.zip
unzip -d /var/www/html/ latest.zip
ln -sf /var/www/html/wordpress /home/vagrant/wordpress

# Make the log files more accessible
# chgrp -R vagrant /var/log/php-fpm
# chmod g+r /var/log/php-fpm/*
chgrp -R vagrant /var/log/nginx

# Copy our wp-config.php file
cp -f /vagrant/wordpress/* /var/www/html/wordpress/

chown -R vagrant:nginx /var/www/html/wordpress 2> /dev/null

# Start up mariadb (mysql)
systemctl enable mariadb
systemctl start mariadb

# Start php-fpm
# systemctl enable php-fpm
# systemctl start php-fpm

# Copy over our nginx config and start nginx
mv -f /etc/nginx/conf.d/default.conf /etc/nginx/
cp -f /vagrant/etc/nginx/conf.d/vagrant.conf /etc/nginx/conf.d/
systemctl enable nginx
systemctl start nginx


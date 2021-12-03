#!/bin/bash
##
##ADDING IPTABLES RULES
sh ./iptables.sh
##
##
##INSTALLING APACHE & MARIADB
##
/usr/bin/cp ./mariadb.repo /etc/yum.repos.d/mariadb.repo
yum -y update
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum -y update
yum-config-manager --disable remi-php54
yum-config-manager --enable remi-php74
yum -y install httpd mariadb mariadb-server php php-common php-mysql php-gd php-xml php-mbstring php-mcrypt wget
/usr/bin/cp ./server2.cnf /etc/my.cnf.d/server.cnf
/usr/bin/cp ./httpd.conf /etc/httpd/conf/httpd.conf
mv /etc/httpd/conf.d/welcome.conf{,_back}
systemctl start httpd mariadb
systemctl enable httpd mariadb
##
##INSTALLING NODE_EXPORTER
##
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.0/node_exporter-1.3.0.linux-amd64.tar.gz
tar -xvzf node_exporter-1.3.0.linux-amd64.tar.gz
useradd --no-create-home --shell /bin/false nodeusr
mv node_exporter-1.3.0.linux-amd64/node_exporter /usr/local/bin/
chown nodeusr:nodeusr /usr/local/bin/node_exporter
/usr/bin/cp node_exporter.service /etc/systemd/system/node_exporter.service
systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter
##
##INSTALLING WORDPRESS
##	
tar -xvzf wp.tar.gz -C /
chown -R apache /var/www/html/wordpress
##
##CONFIGURE MYSQL
##
mysql_secure_installation 
##
##ADD FIRST TABLES AND USERS TO DB
##
mysql -uroot -p3993 < main.db
##
##RESTORING ACTUAL WORDPRESS TABLE
##
mysqldump wordpress < 2021-12-03_wordpress.db
##
##MAKING BACKUP SCHEDULER RULE FOR WORDPRESS TABLE AND FILES
##
cp backup-slave-db.sh /root
chmod +x /root/backup-slave-db.sh
cp backup-wp-files.sh /root
chmod +x /root/backup-wp-files.sh
echo "0 03 * * * root /root/backup-slave-db.sh" >> /etc/crontab
echo "0 04 * * 7 root /root/backup-wp-files.sh" >> /etc/crontab
cat 2021-12-03_wordpress.db | grep "CHANGE MASTER"

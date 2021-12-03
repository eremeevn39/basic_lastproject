#!/bin/bash
##
##ADDING IPTABLES RULES
sh ./iptables.sh
##
##INSTALLING NGINX & MARIADB
##
/usr/bin/cp ./mariadb.repo /etc/yum.repos.d/mariadb.repo
yum -y update
yum -y install nginx mariadb-server mariadb-client wget
/usr/bin/cp ./upstream.conf /etc/nginx/conf.d/upstream.conf
/usr/bin/cp ./nginx.conf /etc/nginx/nginx.conf
/usr/bin/cp ./server.cnf /etc/my.cnf.d/server.cnf 
systemctl start nginx mariadb
systemctl enable nginx mariadb
##
##INSTALLING PROMETHEUS
##
wget https://github.com/prometheus/prometheus/releases/download/v2.32.0-beta.0/prometheus-2.32.0-beta.0.linux-amd64.tar.gz
useradd --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus
tar -xvzf prometheus-2.32.0-beta.0.linux-amd64.tar.gz
cp prometheus-2.32.0-beta.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.32.0-beta.0.linux-amd64/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
chmod -R 700 /usr/local/bin/prometheus
chmod -R 700 /usr/local/bin/promtool
cp -r prometheus-2.32.0-beta.0.linux-amd64/consoles /etc/prometheus
cp -r prometheus-2.32.0-beta.0.linux-amd64/console_libraries /etc/prometheus
cp -r prometheus-2.32.0-beta.0.linux-amd64/prometheus.yml /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
/usr/bin/cp prometheus.yml /etc/prometheus/prometheus.yml
chown prometheus:prometheus /etc/prometheus/prometheus.yml
mkdir -p /var/lib/prometheus
chown -R prometheus:prometheus /var/lib/prometheus/
cp prometheus.service /etc/systemd/system/prometheus.service
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.0/node_exporter-1.3.0.linux-amd64.tar.gz
tar -xvzf node_exporter-1.3.0.linux-amd64.tar.gz
useradd --no-create-home --shell /bin/false nodeusr
mv node_exporter-1.3.0.linux-amd64/node_exporter /usr/local/bin/
chown nodeusr:nodeusr /usr/local/bin/node_exporter
/usr/bin/cp node_exporter.service /etc/systemd/system/node_exporter.service
systemctl daemon-reload
systemctl start prometheus node_exporter
systemctl enable prometheus node_exporter
##
##INSTALLING GRAPHANA
##
/usr/bin/cp grafana.repo /etc/yum.repos.d/grafana.repo
yum -y update
yum -y install grafana-enterprise
systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server.service
mysql_secure_installation
mysql -uroot -p3993 < main.db
mysqldump wordpress < 2021-12-03_wordpress.db

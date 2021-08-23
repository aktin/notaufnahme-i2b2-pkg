#! /bin/bash

echo "Open connection ports in pg_hba.confg"
echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/*/main/pg_hba.conf
echo "host all all ::/0 md5" >> /etc/postgresql/*/main/pg_hba.conf

echo "Set listening address to all in postgresql.conf"
echo "listen_addresses = '*'" >> /etc/postgresql/*/main/postgresql.conf

echo "Activate debugging in i2b2 webclient"
sed -i 's|debug: false|debug: true|' /var/www/html/webclient/i2b2_config_data.js

echo "Open apache2 ports"
sed -i 's/Listen 80/Listen 0.0.0.0:80/' /etc/apache2/ports.conf
sed -i 's/Listen 443/Listen 0.0.0.0:443/g' /etc/apache2/ports.conf

service postgresql restart
service apache2 restart

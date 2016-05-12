#!/bin/bash
apt-get update
apt-get install -y apache2 libapache2-mod-php7.0 php7.0-curl mtr-tiny
a2enmod php7.0
cd /var/www/html
wget https://github.com/vvuksan/fantomTest/archive/v1.0.tar.gz
tar zxf v1.0.tar.gz
ln -sf fantomTest-1.0 fantomtest
cat <<EOF > /var/www/html/index.html
<html><body><h1>Hello World</h1>
<PRE>
EOF

ZONE=`curl metadata/0.1/meta-data/zone | cut -f4 -d/`
MYHOST=`curl metadata/0.1/meta-data/hostname | cut -f1 -d.`

echo "$MYHOST-$ZONE" >> /var/www/html/index.html


cat <<EOF > /var/www/html/ping.php
<?php
header("X-Served-By: $MYHOST");
header("X-Served-Zone: $ZONE");

?>
$MYHOST
EOF


sudo systemctl restart  apache2

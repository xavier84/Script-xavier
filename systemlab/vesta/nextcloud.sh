#!/bin/bash


USER="$1"
PASSWORD="$2"
USERMAIL="$3"
DOMAIN="$4"
USERFTP="$5"
PASSWORDFTP="$6"
PASSWORDNEXT="$7"

PASSWORDSQL="$(date +%s | sha256sum | base64 | head -c 15)"
#VERSION=$(curl -s https://download.nextcloud.com/server/releases/ | tac | grep unknown.gif | sed 's/.*"nextcloud-\([^"]*\).zip.sha512".*/\1/;q')
NEXTVERSION="nextcloud-13.0.0"
WWW="/home/"$USER"/web/"$DOMAIN"/public_html"
DATA="/home/"$USER"/web/"$DOMAIN"/public_html/data-nextcloud"



apt install sudo software-properties-common unzip php7.0-gd php7.0-zip php7.0-mysql php7.0-apcu

v-add-user "$USER" "${PASSWORD}" "$USERMAIL"
v-add-web-domain "$USER" "$DOMAIN"
v-add-web-domain-ftp "$USER" "$DOMAIN" "$USERFTP" "${PASSWORDFTP}"
v-add-database "$USER" wp wp ${PASSWORDSQL}


cd /tmp
wget -v  https://download.nextcloud.com/server/releases/"$NEXTVERSION".zip
unzip -q "$NEXTVERSION".zip -d /tmp
cp -R nextcloud/* "$WWW"
chown -R "$USER":"$USER" "$WWW"
chmod -R 755 "$WWW"


mkdir "$DATA"
chown -R "$USER":"$USER" "$DATA"
chmod -R 750 "$DATA"


cd "$WWW" || exit 1
sudo -u "$USER" php occ maintenance:install \
	--data-dir "$DATA" \
	--database "mysql" \
	--database-name ""$USER"_wp" \
	--database-user ""$USER"_wp" \
	--database-pass "${PASSWORDSQL}" \
	--database-host "localhost" \
	--admin-user "admin" \
	--admin-pass "$PASSWORDNEXT"

sudo -u "$USER" php occ config:system:set \
	trusted_domains 1 \
	--value="$DOMAIN"


#sed -i '$d' /var/www/nextcloud/config/config.php
#echo "  'memcache.local' => '\OC\Memcache\APCu'," >> /var/www/nextcloud/config/config.php
#echo ");" >> /var/www/nextcloud/config/config.php
#/etc/init.d/php5-fpm restart

#!/bin/bash


CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

VERSIOND=$(cat /etc/debian_version)
MDPSQL="$(date +%s | sha256sum | base64 | head -c 15)"
MDPSQLNEXT="$(date +%m | sha256sum | base64 | head -c 15)"
MDPADMIN="$(date +%h | sha256sum | base64 | head -c 15)"
LOG="/root/mdpsql.txt"
VERSION=$(curl -s https://download.nextcloud.com/server/releases/ | tac | grep unknown.gif | sed 's/.*"nextcloud-\([^"]*\).zip.sha512".*/\1/;q')
NEXTVERSION="nextcloud-$VERSION"
WWW="/var/www"
DATA="/var/www/data-nextcloud"
TEST="/var/www/rutorrent/histo.log"

if [[ "$VERSION" =~ 7.* ]] ||  [[ "$VERSION" =~ 8.* ]]; then
	APT="sudo software-properties-common unzip php5-gd php5-zip php5-mysql php5-apcu"
	POOL="/etc/php5/fpm/pool.d/www.conf"
	PHPINI="/etc/php5/fpm/php.ini"
	PHPSOCK="/var/run/php5-fpm.sock"
elif [[ "$VERSION" =~ 9.* ]]; then
	APT="sudo software-properties-common unzip php7.1-gd php7.1-zip php7.1-mysql php7.1-apcu"
	POOLE="/etc/php/7.1/fpm/pool.d/www.conf"
	PHPINI="/etc/php/7.1/fpm/php.ini"
	PHPSOCK="/run/php/php7.1-fpm.sock"
fi



echo -e "${CBLUE}
                                      |          |_)         _|
            __ \`__ \   _ \  __ \   _\` |  _ \  _\` | |  _ \   |    __|
            |   |   | (   | |   | (   |  __/ (   | |  __/   __| |
           _|  _|  _|\___/ _|  _|\__,_|\___|\__,_|_|\___|_)_|  _|


         ____    __   ____  _  _    __    ____  _____  _  _
        (  _ \  /__\ (_  _)( \/ )  /__\  (  _ \(  _  )( \/ )
         )   / /(__)\  )(   )  (  /(__)\  ) _ < )(_)(  )  (
        (_)\_)(__)(__)(__) (_/\_)(__)(__)(____/(_____)(_/\_)
${CEND}"


if [[ "$VERSIOND" =~ 7.* ]] || [[ "$VERSIOND" =~ 8.* ]] || [[ "$VERSIOND" =~ 9.* ]]; then
	if [ "$(id -u)" -ne 0 ]; then
		echo -e "${CRED}Ce script doit être exécuté en root${CEND}"
		exit 1
	fi
else
		echo -e "${CRED}Ce script doit être exécuté sur Debian 7/8/9 exclusivement.${CEND}"
		exit 1
fi


if [ ! -f "$TEST" ]; then
	echo -e "${CRED}Ce script doit être exécuté sur une installation de Ratxabox ou Bonobox de Ex_rat${CEND}"
	exit 1
fi



echo -e "${CYELLOW}Bienvenue sur installation de nextcloud${CEND}"
echo ""
read -p "$(echo -e ${CGREEN}Votre sous-domain : ${CEND})" DOMAIN

echo "" > "$LOG"
echo "Mot de passe root de mysql : $MDPSQL" >> "$LOG"
echo "" >> "$LOG"
echo "Mot de passe bdd nextcloud  : $MDPSQLNEXT" >> "$LOG"
echo "" >> "$LOG"
echo "" >> "$LOG"
echo "Acces de votre cloud id : admin  " >> "$LOG"
echo "Et votre mot de passe cloud : $MDPADMIN" >> "$LOG"
chmod 600 "$LOG"
chown root:root "$LOG"


aptitude install "$APT" -y
echo "mysql-server mysql-server/root_password password $MDPSQL" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MDPSQL" | debconf-set-selections
aptitude install mysql-server -y


mysql -uroot -p"$MDPSQL"<<MYSQL_NEXTCLOUD
CREATE DATABASE nextcloud;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY '$MDPSQLNEXT';
FLUSH PRIVILEGES;
MYSQL_NEXTCLOUD


wget -v  https://download.nextcloud.com/server/releases/"$NEXTVERSION".zip -P "$WWW"
unzip -q "$WWW"/"$NEXTVERSION".zip -d "$WWW"
chown -R www-data:www-data "$WWW"/nextcloud
chmod -R 750 "$WWW"/nextcloud


mkdir "$DATA"
chown -R www-data:www-data "$DATA"
chmod -R 750 "$DATA"


cd $WWW/nextcloud || exit 1
sudo -u www-data php occ maintenance:install \
	--data-dir "$DATA" \
	--database "mysql" \
	--database-name "nextcloud" \
	--database-user "nextcloud" \
	--database-pass "$MDPSQLNEXT" \
	--database-host "localhost" \
	--admin-user "admin" \
	--admin-pass "$MDPADMIN"

sudo -u www-data php occ config:system:set \
	trusted_domains 1 \
	--value="$DOMAIN"

echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> "$POOL"
echo "opcache.enable=1" >> "$PHPINI"
echo "opcache.enable_cli=1" >> "$PHPINI"
echo "opcache.interned_strings_buffer=8" >> "$PHPINI"
echo "opcache.max_accelerated_files=10000" >> "$PHPINI"
echo "opcache.memory_consumption=128" >> "$PHPINI"
echo "opcache.save_comments=1" >> "$PHPINI"
echo "opcache.revalidate_freq=1" >> "$PHPINI"

sed -i '$d' /var/www/nextcloud/config/config.php
echo "  'memcache.local' => '\OC\Memcache\APCu'," >> /var/www/nextcloud/config/config.php
echo ");" >> /var/www/nextcloud/config/config.php
/etc/init.d/php5-fpm restart

wget https://raw.githubusercontent.com/xavier84/Script-xavier/master/nextcloud/nextcloud.conf -P /etc/nginx/sites-enabled/
sed -i "s|@DOMAIN@|$DOMAIN|g;" /etc/nginx/sites-enabled/nextcloud.conf
sed -i "s|@PHPSOCK@|$PHPSOCK|g;" /etc/nginx/sites-enabled/nextcloud.conf
service nginx restart


echo -e "${CYELLOW}Votre domain: $DOMAIN${CEND}"
echo -e "${CYELLOW}Acces de votre cloud id : admin${CEND}"
echo -e "${CYELLOW}Et votre mot de passe cloud : $MDPADMIN${CEND}"
echo ""
echo -e "${CRED}Une sauvegarde des mots de passe dans $LOG${CEND}"

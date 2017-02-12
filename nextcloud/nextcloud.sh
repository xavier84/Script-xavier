#!/bin/bash


CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"


VERSION=$(cat /etc/debian_version)

if [[ "$VERSION" =~ 7.* ]] || [[ "$VERSION" =~ 8.* ]]; then
	if [ "$(id -u)" -ne 0 ]; then
		echo -e "${CRED}Ce script doit être exécuté en root${CEND}"
		exit 1
	fi
else
		echo -e "${CRED}Ce script doit être exécuté sur Debian 7 ou 8 exclusivement.${CEND}"
		exit 1
fi

MDPSQL="$(date +%s | sha256sum | base64 | head -c 15)"
MDPSQLNEXT="$(date +%m | sha256sum | base64 | head -c 15)"
MDPADMIN="$(date +%h | sha256sum | base64 | head -c 15)"
LOG="/root/mdpsql"
VERSION=$(curl -s https://download.nextcloud.com/server/releases/ | tac | grep unknown.gif | sed 's/.*"nextcloud-\([^"]*\).zip.sha512".*/\1/;q')
NEXTVERSION="nextcloud-$VERSION"
WWW="/var/www"
DATA="/var/www/data"


read -p "$(echo -e ${CGREEN}Votre sous-domain : ${CEND})" DOMAIN

echo "" > "$LOG"
echo "Mot de passe root de mysql : $MDPSQL" >> "$LOG"
echo "Mot de passe bdd nextcloud  : $MDPSQLNEXT" >> "$LOG"
echo "Acces de votre cloud id : admin mdp : $MDPADMIN" >> "$LOG"
chmod 600 "$LOG"
chown root:root "$LOG"


aptitude install sudo software-properties-common expect unzip php5-gd php5-mysql -y
echo "mysql-server mysql-server/root_password password $MDPSQL" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MDPSQL" | debconf-set-selections
aptitude install mysql-server -y


/usr/bin/expect <<EOD
set timeout 1200
spawn mysql -u root -p
sleep 1
expect {
"Enter password:" {send "$MDPSQL\n"}
}
expect {
"mysql>" {send "CREATE DATABASE nextcloud;\n"}
}
expect {
"mysql>" {send "GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY '$MDPSQLNEXT';\n"}
}
expect {
"mysql>" {send "FLUSH PRIVILEGES;\n"}
}
expect {
"mysql>" {send "exit;\n"}
}
EOD


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

wget https://raw.githubusercontent.com/xavier84/Script-xavier/master/nextcloud/nextcloud.conf -P /etc/nginx/sites-enabled/nextcloud.conf
sed -i "s|@DOMAIN@|$DOMAIN|g;" /etc/nginx/sites-enabled/nextcloud.conf


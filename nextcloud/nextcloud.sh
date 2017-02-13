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
LOG="/root/mdpsql"
VERSION=$(curl -s https://download.nextcloud.com/server/releases/ | tac | grep unknown.gif | sed 's/.*"nextcloud-\([^"]*\).zip.sha512".*/\1/;q')
NEXTVERSION="nextcloud-$VERSION"
WWW="/var/www"
DATA="/var/www/data"
TEST="/var/www/rutorrent/histo.log"



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


if [[ "$VERSIOND" =~ 7.* ]] || [[ "$VERSIOND" =~ 8.* ]]; then
	if [ "$(id -u)" -ne 0 ]; then
		echo -e "${CRED}Ce script doit être exécuté en root${CEND}"
		exit 1
	fi
else
		echo -e "${CRED}Ce script doit être exécuté sur Debian 7 ou 8 exclusivement.${CEND}"
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
echo "" > "$LOG"
echo "Mot de passe bdd nextcloud  : $MDPSQLNEXT" >> "$LOG"
echo "" > "$LOG"
echo "" > "$LOG"
echo "Acces de votre cloud id : admin  " >> "$LOG"
echo "Et votre mot de passe cloud : $MDPADMIN" >> "$LOG"
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

wget https://raw.githubusercontent.com/xavier84/Script-xavier/master/nextcloud/nextcloud.conf -P /etc/nginx/sites-enabled/
sed -i "s|@DOMAIN@|$DOMAIN|g;" /etc/nginx/sites-enabled/nextcloud.conf
service nginx restart


echo -e "${CYELLOW}Votre domain: $DOMAIN${CEND}"
echo -e "${CYELLOW}Acces de votre cloud id : admin${CEND}"
echo -e "${CYELLOW}Et votre mot de passe cloud : $MDPADMIN${CEND}"
echo ""
echo -e "${CRED}Une sauvegarde des mot de passe dans  /root/mdpsql${CEND}"

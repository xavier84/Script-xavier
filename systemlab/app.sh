#!/bin/bash

USER="$1"
PASSWORD="$2"
USERMAIL="$3"
DOMAIN="$4"
USERFTP="$5"
PASSWORDFTP="$6"

PASSWORDSQL="$(date +%s | sha256sum | base64 | head -c 15)"


v-add-user "$USER" "${PASSWORD}" "$USERMAIL"
v-add-web-domain "$USER" "$DOMAIN"
v-add-web-domain-ftp "$USER" "$DOMAIN" "$USERFTP" "${PASSWORDFTP}"
v-add-database "$USER" wp wp ${PASSWORDSQL}

cd /home/"$USER"/web/"$DOMAIN"/public_html || exit 1
rm index.html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar && php wp-cli.phar --info
php wp-cli.phar core download --locale=fr_FR --force --allow-root
php wp-cli.phar core config --dbname="$USER"_wp --dbuser="$USER"_wp --dbpass=${PASSWORDSQL} --dbhost=localhost --dbprefix=wp_ --allow-root
php wp-cli.phar core install --url="${DOMAIN}" --title="systemlab" --admin_user="$USER" --admin_password="${PASSWORD}" --admin_email="$USERMAIL" --allow-root

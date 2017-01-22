#!/bin/bash
#Author: Xavier


CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"


read -p "$(echo -e ${CGREEN}Choix de l\'utilisateur : ${CEND})" TUSER
# Rclone
user="$TUSER"
cloud="cloud-$user"
enc="Enc$user"
encrypted="cloud-encrypted-$user"


apt-get install -y fuse expect
cd /tmp || exit 1
wget http://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip && cp rclone-*-linux-amd64/rclone /usr/sbin/
rm rclone-current-linux-amd64.zip && rm -Rf rclone-*-linux-amd64
chown root:root /usr/sbin/rclone
chmod 755 /usr/sbin/rclone

#config cloud
chmod 755 ./conf.sh
/usr/bin/expect ./conf.sh $cloud
mkdir /home/$user/cloud
rclone mount $cloud: /home/$user/cloud --allow-other --no-modtime &

#config encryted
chmod 755 ./conf-enc.sh
/usr/bin/expect ./conf-enc.sh $encrypted $enc $cloud
mkdir /home/$user/cloud-encrypted
rclone mount $encrypted: /home/$user/cloud-encrypted --allow-other --no-modtime &

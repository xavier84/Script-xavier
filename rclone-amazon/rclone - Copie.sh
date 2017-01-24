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
cloud="cloud"
enc="Enc"
encrypted="cloud-encrypted"


apt-get install -y fuse expect
#cd /tmp || exit 1
wget http://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip && cp rclone-*-linux-amd64/rclone /usr/sbin/
rm rclone-current-linux-amd64.zip && rm -Rf rclone-*-linux-amd64
chown root:root /usr/sbin/rclone
chmod 755 /usr/sbin/rclone

#config cloud
#chmod 755 ./conf.sh
#/usr/bin/expect ./conf.sh $cloud
mkdir /home/$user/cloud
/usr/bin/expect <<EOF
set timeout 1200
spawn rclone config
sleep 1
expect {
"n) New remote" {send "n\n"}
}
expect {
"name>" {send "$cloud\n"}
}
expect {
"Storage>" {send "1\n"}
}
expect {
"client_id>" {send "\n"}
}
expect {
"client_secret>" {send "\n"}
}
expect {
"Use auto config?" {send "y\n"}
}
expect {
"Yes this is OK" {send "y\n"}
}
expect {
" Edit existing remote" {send "q\n"}
}
interact
EOF

rclone mount $cloud: /home/$user/cloud --allow-other --no-modtime &

#config encryted
#chmod 755 ./conf-enc.sh
#/usr/bin/expect ./conf-enc.sh $encrypted $enc $cloud
mkdir /home/$user/cloud-encrypted
/usr/bin/expect <<EOD
set timeout 1200
spawn rclone config
sleep 1
expect {
"n) New remote" {send "n\n"}
}
expect {
"name>" {send "$encrypted\n"}
}
expect {
"Storage>" {send "5\n"}
}
expect {
"remote>" {send "$cloud:$enc\n"}
}
expect {
"filename_encryption>" {send "2\n"}
}
expect {
"Password or pass phrase for encryption." {send "g\n"}
}
expect {
"Password strength in bits." {send "128\n"}
}
expect {
"Use this password?" {send "y\n"}
}
expect {
"Password or pass phrase for salt. Optional but recommended." {send "g\n"}
}
expect {
"Password strength in bits." {send "128\n"}
}
expect {
"Use this password?" {send "y\n"}
}
expect {
"Yes this is OK" {send "y\n"}
}
expect {
"Current remotes:" {send "q\n"}
}
interact
EOD

rclone mount $encrypted: /home/$user/cloud-encrypted --allow-other --no-modtime &

#!/bin/bash


CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"



read -p "$(echo -e ${CGREEN}Choix de l\'utilisateur : ${CEND})" TUSER
grep -w "$TUSER" /etc/passwd &> /dev/null

if [ $? -eq 1 ]; then
	echo -e "${CRED}Erreur utilisateur "$TUSER" n\'existe pas${CEND}"
	exit 1
else
		if [ ! -f "/etc/apt/sources.list.d/webupd8team-java.list" ];then
		echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
		echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
		apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
		apt-get update && apt-get install oracle-java8-installer -y
	fi

	cd /tmp || exit 1
	wget http://downloads.sourceforge.net/project/filebot/filebot/FileBot_4.6.1/FileBot_4.6.1-portable.zip
	unzip FileBot_4.6.1-portable.zip -d filebot && rm -f FileBot_4.6.1-portable.zip
	mv filebot /home/"$TUSER"/.filebot
	chown -R "$TUSER":"$TUSER" /home/"$TUSER"/.filebot
	chmod a+x /home/"$TUSER"/.filebot/filebot.sh
	chmod a+x /home/"$TUSER"/.filebot/update-filebot.sh
	mkdir /home/"$TUSER"/Media
	mkdir /home/"$TUSER"/Media/Movies
	mkdir /home/"$TUSER"/Media/TV\ Shows
	mkdir /home/"$TUSER"/Media/Music
	chown -R "$TUSER":"$TUSER" /home/"$TUSER"/Media
	chmod -R 755 /home/"$TUSER"/Media


	cat <<- EOF >> /home/"$TUSER"/rtorrent-postprocess
	#!/bin/bash
	TORRENT_PATH=\$1
	TORRENT_NAME=\$2
	TORRENT_LABEL=\$3

	sh /home/$TUSER/.filebot/filebot.sh --lang fr -script fn:amc --output "/home/$TUSER/Media" --log-file "/home/$TUSER/.session/amc.log" --action symlink --conflict override -non-strict --def music=y artwork=n "ut_dir=\$TORRENT_PATH" "ut_kind=multi" "ut_title=\$TORRENT_NAME" "ut_label=\$TORRENT_LABEL" &
	EOF

	chown "$TUSER":"$TUSER" /home/"$TUSER"/rtorrent-postprocess
	chmod a+x /home/"$TUSER"/rtorrent-postprocess

	cat <<- EOF >> /home/"$TUSER"/.rtorrent.rc
	system.method.set_key=event.download.finished,filebot_amc,"execute={/home/$TUSER/rtorrent-postprocess,\$d.get_base_path=,\$d.get_name=,\$d.get_custom1=}"
	EOF


fi
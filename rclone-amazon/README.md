
# Script d'installation rclone/chiffré

Attention c'est une version test donc à prendre avec des pincettes!!!

## Installation:

```
wget https://raw.githubusercontent.com/xavier84/Script-xavier/master/rclone-amazon/rclone.sh
wget https://raw.githubusercontent.com/xavier84/Script-xavier/master/rclone-amazon/conf.sh
wget https://raw.githubusercontent.com/xavier84/Script-xavier/master/rclone-amazon/conf-enc.sh

chmod a+x rclone.sh && ./rclone.sh
```

Choisir un utilisateur (pour qui seras montés les dossiers)

Une fois arrivé sur "Waiting for code..."

![caps1](https://raw.github.com/xavier84/Script-xavier/master/rclone-amazon/token.PNG)

on vas crée un tunnel dynamic,
sur windows ouvrir un autre putty :mettre ip + le port de ssh
puis
1 aller sur tunnel
2 mettre le port 7777
3 choisir dynamic
4 add pour ajouté le port

maintenent clic sur open en bas
reseigné les infos de connection ssh est cest tout..



![caps2](https://raw.github.com/xavier84/Script-xavier/master/rclone-amazon/tunnel.PNG)
![caps3](https://raw.github.com/xavier84/Script-xavier/master/rclone-amazon/socks.PNG)


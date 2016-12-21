Installation automatique openVPN


Script original https://github.com/Nyr/openvpn-install

modifié par Xavier



-partie le serveur,


```
apt-get install ca-certificates

https://raw.githubusercontent.com/xavier84/Script-xavier/master/openvpn/openvpn-install.sh

chmod +x openvpn-install.sh && ./openvpn-install.sh
```



-partie client linux,


installer openvpn, récuperé client.ovpn sur le serveur, puis lancé la commande(si ton certificat ce nomme client.ovpn)

```
openvpn client.ovpn
```



-partie client windows,


installer openvpn-install-*-*-*-*x86_64.exe,

mettre le fichier client.ovpn dans "C:\Program Files\OpenVPN\config"

lancée openvpn GUI en administrateur (clic droit sur icone "executé en tant que administrateur")

puis en bas a droit icon openvpn clic droit "connecter"

Serverinstallation
==================

Betriebssystem
--------------
* Debian aufsetzen
* Standardeinstellungen verwenden, aufpassen, dass man nicht aus versehen einen window manager installiert
* Deutsche Spracheinstellungen
* Netzwerk wie aus dem Wiki bzw. vpnconfig
* Benutzer einrichten
* sudo konfigurieren
* ssh für root deaktivieren

Standardsoftware
----------------
* apticron
* fail2ban
* apache + php
* tinc
* quagga
* zsh
* git
* build-essential
* bison
* flex
* zlib1g-dev

Monitoring
----------
* Firewallregeln
* xinet

OLSR + vtun + innercity-vpn
---------------------------
* OLSR kompilieren
 * make && make libs && make install && make install_libs
* vtun kompilieren
 * ./configure --disable-zlib --disable-lzo --disable-ssl
 * make
 * /usr/bin/strip nach /usr/local/bin/stripe verlinken
 * make install
* Firewallregeln
* github-Repo weimarnetz/vpnconfig verwenden
 * tinc für innercity-vpn: 
  * nach /etc/tinc/wnvpn wechseln und mit tincd -K -c . Schlüssel generieren. Public Key ins Repo einchecken!
  * tinc-down und tinc-up an aktuelle IP-Config anpassen


InterCity-VPN
-------------


Webserver
---------
* Installation Indexseite
* Installation VPN-Status nach /var/www/freifunk/vpn/index.php
* Installation Statusseite
* Installation 404-Seite

Backup
------
* mit duplicity und duply

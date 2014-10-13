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
* xinetd
* zlib1g-dev

Monitoring
----------
* xinetd installieren 
 * ```check_mk``` nach ```/etc/xinetd.d/``` kopieren
 * ```check_mk_agent``` nach ```/usr/bin/``` kopieren
* Firewallregeln
 * Zugriffe sollen nur auf den Monitoringserver bei @andibraeu beschränkt sein
 * ```init.d/iptables``` nach ```/etc/init.d/iptables``` kopieren
 * ```default/iptables``` nach ```/etc/default/iptables``` kopieren
 * iptables-service aktivieren mit ```update-rc.d iptables defaults```
* dyndns-Update für Monitoring-Service
 * ```iptables_dyndns_update.py``` nach ```/usr/local/bin/``` kopieren
 * crontab für root um diesen Eintrag ergänzen: ```*/10 * * * * /usr/local/bin/iptables_dyndns_update.py 2>&1 >/dev/null```
* Monitoring muss nun noch am Server eingerichtet werden

OLSR + vtun + innercity-vpn
---------------------------
* OLSR kompilieren
 * make && make libs && make install && make install_libs
* vtun kompilieren
 * ./configure --disable-zlib --disable-lzo --disable-ssl
 * make
 ** falls /usr/bin/strip fehlt, dann verlinken nach /usr/local/bin/strip
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

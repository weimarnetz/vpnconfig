# Installation Weimarnetz VPN-Server

1. Debian 8 installieren
2. Grundsätzliches Einrichten (Netzwerk, ssh, sudo, etc.)
3. Abhängigkeiten installieren: apt-get install fail2ban apticron tinc zsh git build-essential bison flex xinetd zlib1g-dev monitoring-plugins vim php5 php5-curl nodejs npm
4. OLSR herunterladen und installieren
 * wget http://www.olsr.org/releases/0.9/olsrd-0.9.0.tar.gz
 * tar xfvz olsrd-0.9.0.tar.gz
 * cd olsrd-0.9.0
 * make && make libs
 * make install && make install_libs
 * link anlegen: ln -s /usr/local/sbin/olsrd /usr/sbin/olsrd
 * Cronjob für olsrd: * * * * * /bin/pidof olsrd 1>/dev/null || (/usr/sbin/olsrd -f /etc/olsrd.conf && logger "No olsrd service running -> restart")
5. vtun herunterladen und installieren
 * wget http://downloads.sourceforge.net/project/vtun/vtun/3.0.3/vtun-3.0.3.tar.gz
 * tar xfvz vtun-3.0.3.tar.gz
 * cd vtun-3.0.3
 * ./configure --disable-zlib --disable-lzo --disable-ssl
 * make
 * make install
6. kalua herunterladen und einrichten
 * wget -O /tmp/tarball.tgz http://weimarnetz.de/freifunk/firmware/tarball.tgz
 * cd /
 * tar xfvz /tmp/tarball.tgz
 * rm /bin/sh && ln -s /bin/bash /bin/sh
 * ln -s /etc /var/etc
 * /etc/kalua_init
 * falls der vtun-Port vom Standard (5001) abweicht, trägt man ihn in ```/etc/kalua_uci``` ein: z.B. durch ```echo >>'/etc/kalua_uci' 'system.vpn.port=12345'```
 * . /tmp/loader
 * ```* * * * * test -e /tmp/loader || /etc/kalua_init && . /tmp/loader && _cron vpnserver 2>&1 >/dev/null``` in crontab für root eintragen
7. web installieren (optional)
 * Pfade je nach Webserver beachten, wenn möglich nach /var/www/ umbiegen
 * git clone https://github.com/weimarnetz/web.git
 * cd web
 * sudo npm install -g bower
 * bower install ausführen
 * index.php, inc/, img/, status/, errors/ nach /var/www oder Pfad des Webservers kopieren


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

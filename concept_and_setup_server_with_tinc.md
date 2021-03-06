vpnconfig
=========

VPN Serverconfig für Weimarnetz

Einrichtung
===========

siehe [Anleitung](Setup.md)

VPN zwischen den Servern
========================
1. tinc installieren (je nach OS, mindestens v1.0.19)
2. Kopieren des Verzeichnisses tinc/wnvpn nach  /etc/tinc/wnvpn
```
	root@server:~/vpnconfig# mkdir /etc/tinc/wnvpn
	root@server:~/vpnconfig# cp -vR tinc/wnvpn/* /etc/tinc/wnvpn
```
3. Anpassung der Adressen in tinc-up und tinc-down nach dem IP-Schema (vpn1=.49, vpn2=50, vpn3=51, ...)
4. In /etc/tinc/wnvpn/tinc.conf Namen des Servers eintragen (z.B. vpn3) und die Hosts angeben, zu denen eine Verbindung hergestellt werden soll (ConnectTo=vpn1)
5. Erzeugen von privatem und öffentlichem Schlüssel mit ``sudo tincd -n wnvpn -K``, die Datei mit dem öffentlichen Schlüssel unter hosts sollte noch um die Adresse und der Port ergänzt werden, falls dieser vom Standardport abweicht
6. Der öffentliche Schlüssel sollte in diesem Git-Repository abgelegt werden
```
	root@server:~/vpnconfig# echo "address = vpn4.weimarnetz.de" >tinc/wnvpn/hosts/vpn4
	root@server:~/vpnconfig# echo "port = 658" >>tinc/wnvpn/hosts/vpn4
	root@server:~/vpnconfig# cat /etc/tinc/wnvpn/rsa_key.pub >>tinc/wnvpn/hosts/vpn
	root@server:~/vpnconfig# git add tinc/wnvpn/hosts/vpn4
	root@server:~/vpnconfig# git commit -m "added vpn4"
	root@server:~/vpnconfig# git push
```
7. Eintragen von wnvpn in /etc/tinc/nets.boot, damit das wnvpn-Netz beim Start von tinc gestartet wird
8. Start durch /etc/init.d/tinc start

Ab und zu sollte man das lokale Repository abgleichen:
```
	root@server:~/vpnconfig# git pull
	root@server:~/vpnconfig# cp -vR tinc/wnvpn/hosts/ /etc/tinc/wnvpn/hosts/
	root@server:~/vpnconfig# /etc/init.d/tinc restart
```


JSON-Format
===========
Beschreibt die möglichen Informationen und Felder, die ein Client erwartet:

```
{
  "server" : "DNS-Name des Servers",
  "maxmtu" : "Maximale MTU, die Server anbieten kann",
  "port_vtun_nossl_nolzo" : "Port der VTUN-Instanz, die ohne ssl und ohne lzo kompiliert wurde",
  "port_vtun_nossl_lzo" : "Port der VTUN-Instanz, die ohne ssl aber mit lzo kompiliert wurde",
  "clients" : "Anzahl der verbundenen Clients, wird vom php-script generiert"
}
```
IP-Schema
=========
Jeder VPN-Server bekommt ein /30-Netz aus dem Bereich der Knotennummer 1 (10.63.1.0/26) für das
dummy/ungenutze VTUN-Haupt-Interface. (MainIP im OLSR-jargon)

```
maximal 12 Server:
vpn1: 10.63.1.0/30
vpn2: 10.63.1.4/30
vpn3: 10.63.1.8/30
vpn4: 10.63.1.12/30
vpn5: 10.63.1.16/30
vpn6: 10.63.1.20/30
vpn7: 10.63.1.24/30
vpn8: 10.63.1.28/30
vpn9: 10.63.1.32/30
vpn10: 10.63.1.36/30
vpn11: 10.63.1.40/30
vpn12: 10.63.1.44/30
       10.63.1.48...62/28 (fuer vpnvpn, siehe unten)
```

Für die Verbindung der VPN-Server untereinander (10.63.1.48/28) bauen wir ein tinc-Netz auf,
das die Adressen aus dem letzten Netzbereich verwendet.

```
vpnvpn1:    10.63.1.49/28
vpnvpn2:    10.63.1.50/28
vpnvpn3:    10.63.1.51/28
vpnvpn4:    10.63.1.52/28
vpnvpn5:    10.63.1.53/28
vpnvpn6:    10.63.1.54/28
vpnvpn7:    10.63.1.55/28
vpnvpn8:    10.63.1.56/28
vpnvpn9:    10.63.1.57/28
vpnvpn10:    10.63.1.58/28
vpnvpn11:    10.63.1.59/28
vpnvpn12:    10.63.1.60/28
vpnvpn13:    10.63.1.61/28
vpnvpn14:    10.63.1.62/28

```

Die Verteilung der IPv6-Adressen ist im Wiki unter http://wireless.subsignal.org/index.php?title=IP-System#Wie_kann_die_Verteilung_aussehen beschrieben.

momentan ist folgendes aktiv (id: domain = ip -> admin)
```
vpn1: weimarnetz.de = 77.87.48.19 -> Andi
vpn2: 2.v.weimarnetz.de = 176.9.46.7 -> Andi/UFO
vpn3: weimarnetz/test.vm = 77.87.48.35 -> Andi
vpn4: Chicago = 198.23.155.210 (nossl,lzo) -> Bastian
vpn5: Duesseldorf = 130.255.188.37 (nossl,lzo) -> Bastian
```

Konzept
=======

1. VPN-Server
  * Wir numerieren die DNS-Namen unserer Server durch,
vpn1.weimarnetz.de .. vpnX.weimarnetz.de
  * auf jedem der Server legen wir für jeden Router die Konfiguration
schon im Vorfeld an, 1000 Tap-Devices, 1000 OLSR-Devices. Somit kann
jeder Router ohne Neustart des VPNs auf dem Rootserver eine Verbindung
aufbauen, die anderen Verbindungen werden nicht gestört
2. Router
  * das Tap-Device tap0 und die OLSR-Config wird standardmäßig
eingerichtet, damit muss auch am Router nichts neu gestartet werden
nachdem die Verbindung hergestellt wurde
  * Durch die Anlage der Devices auf dem Rootserver ist auch die
Registrierung nicht mehr notwendig
3. Ablauf
  1. Falls ein direkter Internetzugang vorliegt: Router pingt mit timeout
von 250ms vpn1-vpn10 durch, dauert also 2,5 Sekunden. Der Server mit der
schnellsten Antwortzeit gewinnt. 10 VPN-Server könnten wir
perspektivisch einsetzen. Per DNS kann man die Namen auf andere Server
zeigen lassen
  2. Der Router muss sich zwar nicht registrieren, fragt den Server aber
nach seiner Konfiguration. So können wir die Router schön dumm lassen
und müssen kein Firmwareupdate machen, falls sich etwas ändert. Die
Antwort kann so aussehen:

{
  "server" : "vpn1.weimarnetz.de",
  "port_vtun_nossl_nolzo": "5001",
  "port_vtun_nossl_lzo": "5002",
  "port_vtun_ssl_lzo": "5003",
  "maxmtu": "1452",
  "clients": "23",
  "country": "DE",
}

Es können auch noch weitere Informationen des Servers aufgenommen
werden, mir fallen im Moment nur keine weiteren ein. Der country-code
wird von http://en.wikipedia.org/wiki/ISO_3166-2 genommen. Auf diese
Weise hat der Nutzer evtl. die Chance ein nichtdeutsches Youtube zu bekommen.
  3. Danach verbindet sich der Router wie gehabt und setzt die Routen und
alles wird gut.

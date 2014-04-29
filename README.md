vpnconfig
=========

VPN Serverconfig für Weimarnetz

Einrichtung
===========
1. Anpassung vtundhead.conf und olsrdhead.conf an eigenen Server (IP, Name, HNA)
2. Ausführen des Script vpn_setup.sh erzeugt 1000 Geräte in vtun und olsr
3. Kopieren der erzeugten olsrd.conf und vtund.conf nach /etc/
4. Anpassen der Datei vpn.php in www/ und festlegen der eigenen Informationen
4. Anpassen des Initscripts aus /etc-examples/init.d/vpn (Anpassen der Netzkonfiguration in func_start_olsr() und der vtun-Aufrufe in func_start_vpn()
5. Kopieren des init-scripts nach /etc/init.d/
6. Aufruf von /etc/init.d/vpn start

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
  "Server" : "vpn1.weimarnetz.de",
  "Port_Vtun_noSsl_noLzo":"5001",
  "Port_Vtun_noSsl_Lzo":"5002",
  "maxMTU":"1452"
}
Es können auch noch weitere Informationen des Servers aufgenommen
werden, mir fallen im Moment nur keine weiteren ein.
  3. Danach verbindet sich der Router wie gehabt und setzt die Routen und
alles wird gut.

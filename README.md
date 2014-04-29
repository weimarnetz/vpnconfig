vpnconfig
=========

VPN Serverconfig für Weimarnetz

Konzept
=======

I. VPN-Server
* Wir numerieren die DNS-Namen unserer Server durch,
vpn1.weimarnetz.de .. vpnX.weimarnetz.de
* auf jedem der Server legen wir für jeden Router die Konfiguration
schon im Vorfeld an, 1000 Tap-Devices, 1000 OLSR-Devices. Somit kann
jeder Router ohne Neustart des VPNs auf dem Rootserver eine Verbindung
aufbauen, die anderen Verbindungen werden nicht gestört

II. Router
* das Tap-Device tap0 und die OLSR-Config wird standardmäßig
eingerichtet, damit muss auch am Router nichts neu gestartet werden
nachdem die Verbindung hergestellt wurde
* Durch die Anlage der Devices auf dem Rootserver ist auch die
Registrierung nicht mehr notwendig

III. Ablauf
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

vpnconfig
=========

VPN Serverconfig für Weimarnetz (minimal edition - wip)

Einrichtung
===========

siehe [Konzept und Anleitung](concept_and_setup_server_with_wireguard.md) für wireguard 

hier nur olsr, vtun und iptables 

## requirements 

    # apt install build-essential git bison automake flex iptables-persistent libgps-dev 

## clone configs 

    # git clone https://github.com/weimarnetz/vpnconfig.git 
    # cd vpnconfig 
    # git checkout minimal 

## olsr 

    # git clone https://github.com/OLSR/olsrd
    # cd olsrd 
    # apply patch to prevent OLSR storms: patch -p1 < path-to-vpnconfig-repo/patches/olsr/009-olsrd-seqnr.patch
    # make && make libs && make install && make install_libs 
    # cd ../vpnconfig 
    # cp olsrd.conf /etc/olsrd/olsrd.conf 

In `/etc/olsrd.conf` noch IPs und Interfaces anpassen 

    # cp olsrd.service /etc/systemd/system/olsrd.service 
    # systemctl daemon-reload 
    # systemctl start olsrd
    # systemctl enable olsrd
    # journalctl -u olsrd -f 


## vtun 

    # wget http://downloads.sourceforge.net/project/vtun/vtun/3.0.4/vtun-3.0.4.tar.gz
    # tar -xzvf vtun-3.0.4.tar.gz 
    # cd vtun-3.0.4 
    # apply patch for nat hack: patch < ../vpnconfig/patches/001_vtun_nat_hack.patch 

vtun kompilieren: 

    # aclocal 
    # autoconf 
    # ./configure --disable-zlib --disable-lzo --disable-ssl 
    # ln -s /usr/bin/strip /usr/local/bin/strip
    # make && make install 

Setup: 

    # cd ../vpnconfig 
    # cp vtund.conf /etc/vtund.conf 
    # cp vtund.service /etc/systemd/system/vtund.service 
    # systemctl daemon-reload 
    # systemctl start vtund 
    # systemctl enable vtund
    # journalctl -u vtund -f 

## routing

Alle Pakete, die ins Internet sollen, müssen wir entsprechend routen. Wir können z.B. Masquerading benutzen:

    # iptables -t nat -A POSTROUTING -o enp0s1 -j MASQUERADE 

`enp0s1` mit dem Netzwerk-Interface wo Internet rauskommt ersetzen z.B. `eth0` etc.pp. 

    # iptables-save 

Oder Policy Routing nutzen:

    # Neue Routingtabelle erstellen: echo 42 weimarnetz >> /etc/iproute2/rt_tables 
    # ip route add default via ${route_vpn_gateway} dev ${dev} table weimarnetz
    # ip rule add to 10.0.0.0/8 prio 30001 table main
    # ip rule add from 10.63.0.0/16 prio 30010 table weimarnetz 

## fq-codel 

    # cat >> /etc/sysctl.d/99-fq_codel.conf <<EOF
    net.core.default_qdisc=fq_codel
    EOF
    # sysctl -P 
    // kann auch in rc.local: 
    # tc qdisc replace dev enp0s1 root fq_codel 
    
## apache 

Erstmal Apache weil der CGI-Scripte kann - geht auch mit PHP und co. 

    # apt install apache2 
    # a2enconf cgi 
    
    # cd vpnconfig 
    # cp freifunk-vpn.sh /usr/lib/cgi-bin 
    # chmod +x /usr/lib/cgi-bin/freifunk-vpn.sh 
    
In `/etc/apache/sites-enabled/000-default` das Script angeben: 

    ...
    Include conf-available/serve-cgi-bin.conf
    ScriptAlias "/freifunk/vpn" /usr/lib/cgi-bin/freifunk-vpn.sh
    ...

    # systemctl restart apache2 
    
## neighbors

Das Script `neigh.sh` nach `/usr/local/bin/` kopieren. Dann kann man die OLSR-Nachbarn des Servers sehen.    

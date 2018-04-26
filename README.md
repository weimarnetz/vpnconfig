vpnconfig
=========

VPN Serverconfig für Weimarnetz (minimal edition - wip)

Einrichtung
===========

siehe `master` branch für tinc 

hier nur olsr, vtun und iptables 

## requirements 

    # apt install build-essential git bison automake flex iptables-persistent 

## clone configs 

    # git clone https://github.com/weimarnetz/vpnconfig.git 
    # cd vpnconfig 
    # git checkout minimal 

## olsr 

    # git clone https://github.com/OLSR/olsrd
    # cd olsrd 
    # make && make libs && make install && make install_libs 
    # cd ../vpnconfig 
    # cp olsrd.conf /etc/olsrd/olsrd.conf 

In `/etc/olsrd.conf` noch IPs und Interfaces anpassen 

    # cp olsrd.service /etc/systemd/system/olsrd.service 
    # systemctl daemon-reload 
    # systemctl start olsrd 
    # journalctl -u olsrd -f 


## vtun 

    # wget http://downloads.sourceforge.net/project/vtun/vtun/3.0.4/vtun-3.0.4.tar.gz
    # tar -xzvf vtun-3.0.4.tar.gz 
    # cd vtun-3.0.4 

In `cfg_file.y` folgendes ändern: 

```c 
612 /* Clear the VTUN_NAT_HACK flag which are not relevant to the current operation mode */
613 inline void clear_nat_hack_flags(int svr)
614 {
```

zu 

```c
612 /* Clear the VTUN_NAT_HACK flag which are not relevant to the current operation mode */
613 extern inline void clear_nat_hack_flags(int svr)
614 {
```

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
    # journalctl -u vtund -f 

## iptables 

    # iptables -t nat -A POSTROUTING -o enp0s1 -j MASQUERADE 

`enp0s1` mit dem Netzwerk-Interface wo Internet rauskommt ersetzen z.B. `eth0` etc.pp. 

    # iptables-save 


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
    
    

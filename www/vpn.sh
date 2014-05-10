#!/bin/sh

# we want to output a (prettyfied) JSON,
# which we can output to '/var/www/freifunk/vpn/vpn.json'
# and this is called via a symlinked 'index.html' -> 'vpn.json'
# every 60/300? seconds from CRONd
#
# country-code: http://en.wikipedia.org/wiki/ISO_3166-2

COUNT_CLIENTS=$( grep tap[0-9] /proc/net/dev | wc -l )

cat <<EOF
{
  "server": "vpn2.weimarnetz.de",
  "country": "DE",
  "maxmtu": "1450",
  "port_vtun_nossl_nolzo": "5063",
  "port_vtun_nossl_lzo": "5064",
  "port_vtun_ssl_lzo": "5065",
  "clients": "$COUNT_CLIENTS"
}
EOF

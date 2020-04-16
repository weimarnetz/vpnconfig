#!/bin/sh

# we want to output a (prettyfied) JSON,
# which we can output to '/var/www/freifunk/vpn/vpn.json'
# and this is called via a symlinked 'index.html' -> 'vpn.json'
# every 60/300? seconds from CRONd
#
# country-code: http://en.wikipedia.org/wiki/ISO_3166-2

COUNT_CLIENTS=$( grep tap[0-9] /proc/net/dev | wc -l )
echo "Content-type: application/json"
echo ""
cat <<EOF
{
  "server": "segfault.gq",
  "country": "NL",
  "maxmtu": "1280",
  "port_vtun_nossl_nolzo": "5001",
  "clients": "$COUNT_CLIENTS"
}
EOF

#!/bin/bash

# creates vtun and olsr config files for 1000 nodes
# node names: Node$Nr

# vtund.conf path
VTUNDCONF="vtund.conf"
VTUNDCONFHEAD="vtundhead.conf"
# olsrd.conf path
OLSRDCONF="olsrd.conf"
OLSRD6CONF="olsrd6.conf"
# olsrd.conf_head for individual server setting
OLSRDCONFHEAD="olsrdhead.conf"
OLSRD6CONFHEAD="olsrd6head.conf"
# mtu for tap devices
MTU=1450
IPV6PREFIX="2001:0bf7:1930:"
IPV6NETMASK="64"
#network for nodenumber (every node has /56 network)
IPV6NETWORK="ff"

# write olsrd head
cat "${OLSRDCONFHEAD}" > "${OLSRDCONF}"
cat "${OLSRD6CONFHEAD}" > "${OLSRD6CONF}"
cat "${VTUNDCONFHEAD}" > "${VTUNDCONF}"

for NUMBER in {2..1000}
do
  IP3="$(( $NUMBER - (255*(($NUMBER-1)/255))  ))"
  IP4="$(( ($NUMBER / 256 * 64) + 29 ))"
  CLIENTIP="10.63.$IP3.$IP4"
  SERVERIP="10.63.$IP3.$(( $IP4+1))"
  MACSUFFIX=`printf "%04d" $NUMBER | sed 's/^\(.\{2\}\)/\1:/'`
  NUMBERINHEX=`echo "obase=16; $NUMBER" | bc `
  if [ "$NUMBER" -ge "256" ]; then
    NUMBERINHEX=`echo "obase=16; $NUMBER" | bc |sed 's/^.*\(.\)\(..\)$/\1:\2/g' `
    IPV6PREFIX="2001:0bf7:193"
  fi
  IPV6="$IPV6PREFIX${NUMBERINHEX,,}$IPV6NETWORK"

  cat >> "${OLSRDCONF}" <<EOF

Interface "tap$NUMBER" {
  Ip4Broadcast $CLIENTIP 
  HelloInterval 3.0           
  HelloValidityTime 125.0     
  TcInterval 2.0              
  TcValidityTime 500.0        
  MidInterval 25.0            
  MidValidityTime 500.0       
  HnaInterval 10.0            
  HnaValidityTime 125.0
}
EOF

  cat >> "${OLSRD6CONF}" <<EOF
Interface "tap$NUMBER" {
  HelloInterval 3.0           
  HelloValidityTime 125.0     
  TcInterval 2.0              
  TcValidityTime 500.0        
  MidInterval 25.0            
  MidValidityTime 500.0       
  HnaInterval 10.0            
  HnaValidityTime 125.0
}

EOF
  
  cat >> "${VTUNDCONF}" <<EOF

Node$NUMBER {
        device tap$NUMBER ;
        passwd ff ;

        up {
                program "logger -p daemon.info -t vtund[helper] link_up tap$NUMBER:Node$NUMBER" wait;
                program "ip link set dev tap$NUMBER down" wait;
                program "ip link set dev tap$NUMBER address 02:ba:d1:de:$MACSUFFIX" wait;
                program "ip address add $SERVERIP/30 dev tap$NUMBER" wait;
                program "ip -6 address add $IPV6::2/$IPV6NETMASK dev tap$NUMBER" wait;
                program "ip link set dev tap$NUMBER mtu $MTU up" wait;
        } ;

        down {
                program "logger -p daemon.info -t vtund[helper] link_down tap$NUMBER:Node$NUMBER" ;
                program "ip address del $SERVERIP/30 dev tap$NUMBER" wait;
                program "ip -6 address del $IPV6::2/$IPV6NETMASK dev tap$NUMBER" wait;
                program "ip link set dev tap$NUMBER down" wait;
        } ;
}
EOF

done

#!/bin/bash

# creates vtun and olsr config files for 1000 nodes
# node names: Node$Nr

# vtund.conf path
VTUNDCONF="vtund.conf"
VTUNDCONFHEAD="vtundhead.conf"
# olsrd.conf path
OLSRDCONF="olsrd.conf"
# olsrd.conf_head for individual server setting
OLSRDCONFHEAD="olsrdhead.conf"

# write olsrd head
cat "${OLSRDCONFHEAD}" > "${OLSRDCONF}"
cat "${VTUNDCONFHEAD}" > "${VTUNDCONF}"

for NUMBER in {2..1000}
do
  IP3="$(( $NUMBER - (255*(($NUMBER-1)/255))  ))"
  IP4="$(( ($NUMBER / 256 * 64) + 29 ))"
  CLIENTIP="10.63.$IP3.$IP4"
  SERVERIP="10.63.$IP3.$(( $IP4+1))"
  MACSUFFIX=`printf "%04d" $NUMBER | sed 's/^\(.\{2\}\)/\1:/'`
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
  
  cat >> "${VTUNDCONF}" <<EOF

Node$NUMBER {
        device tap$NUMBER ;
        passwd ff ;

        up {
                program "logger -p daemon.info -t vtund[helper] link_up tap$NUMBER:Node$NUMBER" wait;
                program "ip link set dev tap$NUMBER down" wait;
                program "ip link set dev tap$NUMBER address 02:ba:d1:de:$MACSUFFIX" wait;
                program "ip address add $SERVERIP/30 dev tap36 label tap$NUMBER:Node$NUMBER" wait;
                program "ip link set dev tap$NUMBER mtu 1500 up" wait;
        } ;

        down {
                program "logger -p daemon.info -t vtund[helper] link_down tap$NUMBER:Node$NUMBER" ;
                program "ip address del $SERVERIP/30 dev tap$NUMBER label tap$NUMBER:NODE$NUMBER" wait;
                program "ip link set dev tap$NUMBER down" wait;
        } ;
}
EOF

done

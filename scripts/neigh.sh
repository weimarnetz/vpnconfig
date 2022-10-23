#!/bin/sh

ip r|grep "metric 1"| grep "dev tap"|grep -v "/26" |grep -v via
echo
echo "$(ip r|wc -l) routes"
echo
wget -q -O - http://127.0.0.1:2006/neighbours|sed -e's/LinkQuality/LQ/;s/Hysteresis/Hyst./;s/Willingness/Will./'
wget -q -O - http://[::1]:8081/neighbours|sed -e's/LinkQuality/LQ/;s/Hysteresis/Hyst./;s/Willingness/Will./'

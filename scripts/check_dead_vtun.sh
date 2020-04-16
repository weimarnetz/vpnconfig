#!/bin/sh

for i in `ls /sys/class/net/ | grep tap`; 
 do echo ""; 
 echo $i; 
 val1=`cat /sys/class/net/$i/statistics/rx_packets`; 
 echo $val1; 
 sleep 3; 
 val2=`cat /sys/class/net/$i/statistics/rx_packets`; 
 echo $val2;
 if [ $val1 -eq $val2 ]; then 
  echo "Mist"; 
  sudo kill `pgrep -f "$i "`; 
 fi  ;
done

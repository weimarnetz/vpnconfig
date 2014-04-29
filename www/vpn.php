<?
  $serverinfo['server'] = "vpn2.weimarnetz.de";
  $serverinfo['maxmtu'] = "1500";
  $serverinfo['port_vtun_nossl_nolzo'] = "5063";
  $serverinfo['clients'] = trim(shell_exec("ip a|grep \"^[0-9].*tap\"|wc -l"));
  header('Content-Type: application/json');
  echo json_encode($serverinfo);

?>

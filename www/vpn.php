<?
  $serverinfo['server'] = "vpn2.weimarnetz.de";
  $serverinfo['maxmtu'] = "1500";
  $serverinfo['port_vtun_nossl_nolzo'] = "5063";
  $serverinfo['clients'] = trim(shell_exec("grep tap[0-9] /proc/net/dev | wc -l"));

  header('Content-Type: application/json');
  echo json_encode($serverinfo, JSON_PRETTY_PRINT);
?>

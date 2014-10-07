#!/usr/bin/python

import os

def gettextoutput(cmd):
    """Return (status, output) of executing cmd in a shell."""
    pipe = os.popen('{ ' + cmd + '; } 2>&1', 'r')
    pipe = os.popen(cmd + ' 2>&1', 'r')
    text = pipe.read()
    if text[-1:] == '\n': text = text[:-1]
    return text

home_dyndns = "home.andi95.de"
log_dyndns = "/var/log/iptables_dyndns_update.log"
last_dyndns = gettextoutput("cat " + log_dyndns)
cur_dyndns = gettextoutput("host " + home_dyndns)
cur_iptables = gettextoutput("/sbin/iptables -S INPUT |grep \"\\-A INPUT \\-s\" -m 1|cut -d \" \" -f 4|cut -d \"/\" -f 1")

print "Log: "+ last_dyndns
print "Cur: "+ cur_dyndns
print "IPT: "+ cur_iptables

if last_dyndns == cur_dyndns and cur_iptables in last_dyndns and cur_iptables != "":
    print "IPs match, no restart necessary"
else:
    print "Updating last IP with current"
    os.system("echo '" + cur_dyndns + "' > " + log_dyndns)
    print "Restarting iptables to update"
    os.system("/sbin/iptables-restore < /etc/default/iptables")
    #os.system("/etc/init.d/squid3 restart")

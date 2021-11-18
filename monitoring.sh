#!/bin/bash
wall $'#Architecture:' `uname -a` \
$'\n#CPU physical : '`nproc` \
$'\n#vCPU :' `cat /proc/cpuinfo | grep processor | wc -l` \
$'\n#Memory Usage:' `free -m | grep Mem | awk '{printf "%d/%d (%.1f%%)", $3, $2, $3*100/$2}'` \
$'\n#Disk Usage: '`df -h | grep root | awk '{print $3"/"$2" ("$5")"}'` \
$'\n#CPU load: '`cat /proc/loadavg | awk '{printf "%.1f%%", $1}'` \
$'\n#Last boot:' `who -b | awk '{print $3" "$4}'` \
$'\n#LVM use:' `lsblk |grep lvm | awk '{if ($1) {print "yes";exit;} else {print "no"} }'` \
$'\n#Connection TCP:' `netstat -an | grep ESTABLISHED |  wc -l` "ESTABLISHED" \
$'\n#User log:' `who | wc -l` \
$'\nNetwork: IP' `hostname -I`"("`ip a | grep link/ether | awk '{print $2}'`")" \
$'\n#Sudo :' `cat /var/log/sudo/sudo.log | grep COMMAND | wc -l` "cmd"

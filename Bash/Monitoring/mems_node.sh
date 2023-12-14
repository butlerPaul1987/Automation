#!/bin/bash
# title  : Mems_node.sh
# desc   : Monitors the Apache2 accesslog to see if the traffic manager 
# author : Paul Butler
# date   : 14/12/2023

# Sets the hour variable and command to run 
HOUR=$(date +"%H")
CMD=$(cat /var/log/apache2/toobmgt_access.log | grep '/heartbeat/probe.php HTTP/1.1" 403 487' | awk '{print $1}' | sort | uniq | wc -l)

# if the CMD variable returns nothing, then set STATUS to normal 
# if the CMD variable returns results set STATUS to WARNING
if [[ $CMD ]]; then
    STATUS=WARNING
else
    STATUS=NORMAL
fi

# Output results to set format
cat << @EOF
TM_STATUS=$STATUS
TM_IPS=$CMD
LASTCHECK=$(date '+%F %T')
@EOF

#!/bin/bash
# title  : Mems_nodestatus.sh
# desc   : Monitors the node-admin status
# author : Paul Butler
# date   : 30/03/2023

# nb: nodestatus.log will be generated every hour.

# output node-admin status
/bin/node-admin status >/var/log/location/nodestatus.log 2>&1

# start variables
NODESTATUS=$(cat /var/log/location/nodestatus.log | cut -d: -f2 | grep -E 'DOWN|UNAVAILABLE')
# end variables

# work out the status of the node-admin status output
if [[ $NODESTATUS ]]; then
        STATUS=WARNING
else
        STATUS=NORMAL
fi

# add a reason
if [[ $NODESTATUS = *"DOWN"* ]]; then
        REASON="A service is down"
elif [[ $NODESTATUS = *"UNAVAILABLE"* ]]; then
        REASON="A node is down"
else
        REASON="Nodes and services available"
fi

# create a res file
cat << @EOF
STATUS=$STATUS
REASON=$REASON
LASTCHECK=$(date '+%F %T')
@EOF

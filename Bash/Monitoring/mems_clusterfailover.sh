#!/bin/bash
# title  : Mems_clusterfailover.sh
# desc   : Monitors the node to check which host has the VIP
# author : Paul Butler
# date   : 03/04/2023


# start variables
HOSTVIP=$(ip a | grep 0.0.0.0)
# end variables

# main block
if [[ $HOSTVIP ]]; then
        STATUS=NORMAL
                REASON="node1 has the vip: 0.0.0.0"
else
        STATUS=WARNING
                REASON="node2 has the vip: 0.0.0.0"
fi

# create a res file
cat << @EOF
CLUSTERSTATUS=$STATUS
CLUSTERREASON=$REASON
LASTCHECK=$(date '+%F %T')
@EOF

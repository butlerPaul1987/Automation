#!/bin/bash
# title  : Mems_sftpsync.sh
# desc   : Monitors the if files have synced across both instances
# author : Paul Butler
# date   : 31/03/2023

# mcp01 - get md5sum
md5sum /home/location/location/location/location/*.sef | cut -d" " -f1 > /var/log/location/location-md5.log

# mcp02
ssh root@location md5sum /home/location/location/location/location/*.sef | cut -d" " -f1 > /var/log/location/location-md5.log

# test
DIFF=$(diff /var/log/location/location-md5.log /var/log/location/location-md5.log)

# work out the status of the diff status output
if [[ $DIFF ]]; then
        STATUS=WARNING
        REASON="MD5SUM does not match"
else
        STATUS=NORMAL
        REASON="MD5SUM matches!"
fi



# create a res file
cat << @EOF
SFTP_STATUS=$STATUS
SFTP_REASON=$REASON
LASTCHECK=$(date '+%F %T')
@EOF

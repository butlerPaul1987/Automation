#!/bin/bash
cd "/c/Users/Paul.Butler/Documents/YAP"

echo "Current directory: $PWD"
DATE=$(date '+%Y-%m-%d')
TIMENOW=$(date "+%d%b%Y")
CURL=$(curl -s -D - -o /dev/null -H "X-Api-Key: xxxxxxxxxxxxxxxxxx" "https://api.newest.com")
LastModified=$($CURL | 	grep Last | awk '{print $3, $4, $5}')
FileName=$($CURL| grep 'filename' | awk {'print $3'})


writelog () {
	cd "/c/Users/Paul.Butler/Documents/YAP"
	LogTime=$(date '+%Y-%m-%d %H:%M:%S')
	echo "[$LogTime] $1"
	echo "[$LogTime] $1" >> "YAP.log"
}



if [ "$LastModified" < "$TIMENOW" ]; then
	# 
	writelog "There are new files to download"
	writelog "Starting file download, $FileName"
	curl -o FILES/YAP_${DATE}.xml -H "X-Api-Key: xxxxxxxxxxxxxxxxxx" "https://api.newest.com"

	writelog "Download complete"

else
	writelog "No new sanction files to download"
fi

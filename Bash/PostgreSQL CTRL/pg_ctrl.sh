#!/bin/bash

# By:       PButler
# Title:    postgres-ctrl.sh
# Date:     19/07/2023 @ 16:48

#@
#@ USAGE: ./postgres-ctrl.sh ACTION SETTING [RESTOREFILE]
#@
#@ BACKUP EXAMPLE: ./postgres-ctrl.sh --option backup --host cyient --port 5432
#@ RESTORE EXAMPLE: ./postgres-ctrl.sh --option restore --host cyient --port 5432 --restore-file /var/backups/postgresql/backup.sql
#@
#@ ACTION
#@   -h|--help                          Shows the help output
#@   -o|--option                        i.e : backup, all-host-backup or restore
#@
#@ SETTING
#@   -s |--host                         i.e : Cyient
#@   -p |--port                         i.e: 5432 (default) or any port running
#@
#@ RESTOREFILE
#@  -rf|--restore-file                  Set restore file i.e. /var/backups/postgresql/backup.sql
#@

Usage(){
cat $0 | grep '^#@' | sed -e 's/^#@//g'
echo -e "$*\n"
return 0
}

# - printf colours
WARNING='\033[1;31m'
SUCCESS='\033[1;32m'
INFO='\033[1;33m'
NC='\033[0m' # No Colour

# Set vars up
Init(){
  SET_OPTION=
  SET_ALLHOST=
  SET_HOST=
  SET_PORT=
  SET_RESTORE_FILE=
}

# Check for missing directory/ .pgpass file/...
! test -d "/var/backups/postgresql" && echo "Missing directory /var/backups/postgresql" && exit 1
! test -f "/root/.pgpass" && echo "Missing .pgpass file - passwordless access won't work" && exit 1

progArgs(){
  while [ ! -z "$1" ]; do
    case $1 in
    # SETTINGS =========
      "-o"|"--option" )
        shift; SET_OPTION=$1; SET="true"
        ;;
    # HOST/PORT =========
      "-s"|"--host" )
        shift; SET_HOST=$1; SET="true"
        ;;
      "-as"|"--all-host" )
        shift; SET_ALLHOST=$1; SET="true"
        ;;
      "-p"|"--port" )
        shift; SET_PORT=$1; SET="true"
        ;;
    # RESTORE FILE
      "-rf"|"--restore-file" )
        shift; SET_RESTORE_FILE=$1; SET="true"
        ;;
    # HELP ===============
      "-h"|"--help" )
        Usage "Help" && exit 0;;
      * ) Usage "Unknown argument '$1'" && exit 2;;
    esac
    shift
  done
}

# Let's create some functions
pgOption(){
  # Check for options then perform action
  DATETIME=$(date +%Y%m%j%H%M)
  BACKFILE="/var/backups/postgresql/pgdump-${SET_HOST}-${DATETIME}.sql"

  # Backup Process
  if [ $SET_OPTION = "backup" ]; then
      pg_dumpall --host $SET_HOST --username 'sysbackup' --database 'postgres' --verbose --clean -f $BACKFILE

  # All host Process:
  #elif [ $SET_OPTION = "all-host-backup" ]; then
  #    for h in $hosts; 
  #      BACKFILE="/var/backups/postgresql/pgdump-${h}-${DATETIME}.sql"
  #      do pg_dumpall --host $h --username 'sysbackup' --database 'postgres' --verbose --clean -f $BACKFILE; 
  #    done

  # Restore Process:
  elif [ $SET_OPTION = "restore" ]; then
      psql -U sysbackup -h $SET_HOST -p $SET_PORT < $SET_RESTORE_FILE

  # else ask for valid selection
  else
      printf "Please select a valid option: ${INFO}[BACKUP]${NC} or ${INFO}[RESTORE]${NC}\n"
  fi
}

# Main ------------------------
Init \
&& pgOption \
&& progArgs $*


exit $?
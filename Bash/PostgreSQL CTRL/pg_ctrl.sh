#!/bin/bash
# By:       PButler
# Title:    postgres-ctrl.sh
# Date:     19/07/2023 @ 16:48
# Version:  v1.0 - Initial Build

#   pgpass example format:
#   hostname:port:database:username:password
#   notes: hostname must match exactly...

#@
#@ USAGE:
#@       ./postgres-ctrl.sh ACTION SETTING [RESTOREFILE]
#@
#@ BACKUP EXAMPLE:
#@       ./postgres-ctrl.sh --option backup --host hostname --port 5432
#@ CRON EXAMPLE:
#@       ./postgres-ctrl.sh --option cron 
#@ RESTORE EXAMPLE:
#@       ./postgres-ctrl.sh --option restore --host hostname --port 5432 --restore-file /var/backups/postgresql/backup.sql.bz2
#@
#@ ACTION
#@   -h|--help                         Shows the help output
#@   -o|--option                       i.e : backup, restore or cron
#@
#@ SETTING
#@   -s|--host                         i.e : hostname
#@   -p|--port                         i.e : 5432 (default) or any port running
#@   -u|--user                         i.e : sysadmin etc
#@
#@ RESTOREFILE
#@  -rf|--restore-file                 Set restore file i.e. /var/backups/postgresql/backup.sql
#@
#@
#@ LOG FIE GENERATED:                  /var/backups/postgresql/${HOST}-${DATETIME}.log

# Set vars up
SET_OPTION=
SET_HOST=
SET_ALLHOST=
SET_PORT=
SET_RESTORE_FILE=
SET_USER=

while [ ! -z "$1" ]; do
  case $1 in
  # SETTINGS =========
    "-o"|"--option" )
      shift; SET_OPTION=$1; SET="true"
      ;;
    "-u"|"--user" )
      shift; SET_USER=$1; SET="true"
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

# Log colour sets
WARNING='\033[1;31m'  # Red
SUCCESS='\033[1;32m'  # Green
INFO='\033[1;33m'     # Yellow

# Banner colour sets
LCYAN='\033[1;36m'    # Cyan
MAGEN='\033[1;35m'    # Magenta
NC='\033[0m'          # No Colour

# functions
Usage(){
    cat $0 | grep '^#@' | sed -e 's/^#@//g'
    echo -e "$*\n"
    return 0
}

LogWrite(){
    DATETIME=$(date '+%Y%m%d')
    FILE="/var/backups/postgresql/${SET_HOST}-${DATETIME}.log"
    printf "$(date '+%b %d %T') : $1\n" >> $FILE;
}

banner(){
    printf "
    ${LCYAN}██████╗ ${MAGEN} ██████╗       ${LCYAN} ██████╗████████╗██████╗ ██╗
    ${LCYAN}██╔══██╗${MAGEN}██╔════╝       ${LCYAN}██╔════╝╚══██╔══╝██╔══██╗██║
    ${LCYAN}██████╔╝${MAGEN}██║  ███╗█████╗${LCYAN}██║        ██║   ██████╔╝██║
    ${LCYAN}██╔═══╝ ${MAGEN}██║   ██║╚════╝${LCYAN}██║        ██║   ██╔══██╗██║
    ${LCYAN}██║     ${MAGEN}╚██████╔╝      ${LCYAN}╚██████╗   ██║   ██║  ██║███████╗
    ${LCYAN}╚═╝     ${MAGEN} ╚═════╝       ${LCYAN} ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝${NC}
    \n"
}

# Check for missing directory / .pgpass file
! test -d "/var/backups/postgresql" && banner && echo "Missing directory /var/backups/postgresql - please create" && exit 1
! test -f "/root/.pgpass" && banner && echo "Missing .pgpass file - passwordless access will not work" && exit 1

banner
printf "[${INFO}-${NC}]: Adding data into variables\n"
DATETIME=$(date +%Y%m%d%H%M)
BACKFILE="/var/backups/postgresql/pgdump-${SET_HOST}-${DATETIME}.sql"
printf "[${SUCCESS}+${NC}]: Complete\n"

##################
# Backup Process #
##################
if [[ $SET_OPTION = "backup" ]]; then
    printf "[${INFO}-${NC}]: Creating backup\n"
    LogWrite "PGDUMP -> $BACKFILE"
    /usr/bin/pg_dumpall --host $SET_HOST --username $SET_USER --database 'postgres' --verbose --clean -f $BACKFILE
    # Perform check
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
      # session variables
      SIZE=$(ls -al $BACKFILE | awk '{print $5}')
      LogWrite "OK - PGDUMP -> $BACKFILE Size=$SIZE"
      printf "[${SUCCESS}+${NC}]: Complete\n"

      # Compress the backup
      printf "[${INFO}-${NC}]: Compressing backup\n"
      LogWrite "Archiving $BACKFILE ..."

      /bin/bzip2 $BACKFILE  # this can be slow
      RESULT=$?
      if [ $RESULT -eq 0 ]; then
        NEWBACKFILE="$BACKFILE.bz2"
        SIZE=$(ls -al $NEWBACKFILE | awk '{print $5}')
        LogWrite "\tOK - Created -> $NEWBACKFILE" 
        LogWrite "\tSize=$SIZE"
        printf "[${SUCCESS}+${NC}]: Complete\n"
      else
        LogWrite "FAIL - PGDUMP Failed!"
        printf "[${WARNING}@${NC}]: Failed\n"
      fi
    else
      SIZE=$(ls -al $BACKFILE | awk '{print $5}')
      LogWrite "FAIL - PGDUMP -> $BACKFILE Size="
      printf "[${WARNING}@${NC}]: Failed\n"
    fi

###################
# Restore Process #
###################
elif [[ $SET_OPTION = "restore" ]]; then
    printf "[${INFO}-${NC}]: Creating restore with file: $SET_RESTORE_FILE\n"
    /bin/bzip2 -dkf $SET_RESTORE_FILE
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
      printf "[${SUCCESS}+${NC}]: Complete\n"
    else
      printf "[${WARNING}@${NC}]: Failed\n"
    fi

    # can probably be better coded, unsure how.. will ask Bjorn :)
    RESTORE_FILE=${SET_RESTORE_FILE::-4}
    /usr/bin/psql -U $SET_USER -h $SET_HOST -p $SET_PORT < $RESTORE_FILE
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
      printf "[${SUCCESS}+${NC}]: Complete\n"
    else
      printf "[${WARNING}@${NC}]: Failed\n"
    fi

################
# Cron Process #
################
elif [[ $SET_OPTION = "cron" ]]; then
    printf "[${INFO}-${NC}]: Creating backup\n"
    HOSTLIST="host 1 host 2 host 3 etc etc"
    printf "Host list: $HOSTLIST\n"
    for SET_HOST in $HOSTLIST; do
      printf "Backing up.. '$SET_HOST'\n"

      # cron variables
      BACKUPFILE="/var/backups/postgresql/pgdump-${SET_HOST}-${DATETIME}.sql"
      printf "Creating file.. '$BACKUPFILE'\n"
      USER=$(cat ~/.pgpass | grep $SET_HOST | awk -F : {'print $4'})

      LogWrite "PGDUMP -> $BACKFILE"
      /usr/bin/pg_dumpall --host $SET_HOST --username $USER --database 'postgres' --verbose --exclude-database='azure_*' --clean -f $BACKUPFILE
      # Perform check
      RESULT=$?
      if [ $RESULT -eq 0 ]; then
        # session variables
        SIZE=$(ls -al $BACKUPFILE | awk '{print $5}')
        LogWrite "\tOK - PGDUMP -> $BACKUPFILE Size=$SIZE"
        printf "[${SUCCESS}+${NC}]: Complete\n"

        # Compress the backup
        printf "[${INFO}-${NC}]: Compressing backup\n"
        LogWrite "Archiving $BACKUPFILE ..."
        /bin/bzip2 $BACKUPFILE  # this can be slow
        RESULT=$?
        if [ $RESULT -eq 0 ]; then
          NEWBACKFILE="$BACKUPFILE.bz2"
          SIZE=$(ls -al $NEWBACKFILE | awk '{print $5}')
          LogWrite "\tOK - Created -> $NEWBACKFILE Size=$SIZE"
          printf "[${SUCCESS}+${NC}]: Complete\n"
        else
          LogWrite "FAIL - Compression Failed!"
          printf "[${WARNING}@${NC}]: Failed\n"
        fi
      else
        SIZE=$(ls -al $BACKUPFILE | awk '{print $5}')
        LogWrite "FAIL - PGDUMP -> $BACKUPFILE Size="
        printf "[${WARNING}@${NC}]: Failed\n"
      fi
    done

# else ask for valid selection
else
    Usage
fi

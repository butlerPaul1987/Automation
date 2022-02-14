#!/bin/bash
###########################################################################################################
#    .SYNOPSIS
#        Basic Bash Script to install MySQL
#    .NOTES
#        ** NEEDS TO BE RUN AS SUPER USER **
#        In progress, not for use in production - just yet.
#    .DESCRIPTION
#        This will update and upgrade system, then install latest MYSQL version
#    .OUTPUTS
#        N/A
#    .INPUTS
#        N/A
#    .NOTES
#        Version:        Author         Creation Date:              Purpose/Change:
#        1.0             PButler        07/02/2022                  Initial Build
#
###########################################################################################################

# Initial variables
VERSION="v1.0"
SECTION="MySQL Installer"
CYAN='\033[0;36m'
LIGHTCYAN='\033[1;36m'
YELLOW='\033[1;33m' 
NC='\033[0m' # No Color
LineBreak="|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx[ $VERSION : $SECTION ]xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|"

# check if superuser
if [ "$EUID" -ne 0 ]
  then printf "Please run ${YELLOW}'sudo bash bash.sh'${NC} to proceed %b\n"
  exit
fi

# set a title
printf "
${CYAN}               /xx      /xx/xx     /xx/xxxxxx  /xxxxxx /xx
              | xxx    /xx|  xx   /xx/xx__  xx/xx__  x| xx
              | xxxx  /xxxx\  xx /xx| xx  \__| xx  \ x| xx
              | xx xx/xx xx \  xxxx/|  xxxxxx| xx  | x| xx
              | xx  xxx| xx  \  xx/  \____  x| xx  | x| xx
${LIGHTCYAN}              | xx\  x | xx   | xx   /xx  \ x| xx/xx x| xx
              | xx \/  | xx   | xx  |  xxxxxx|  xxxxxx| xxxxxxxx
              |__/     |__/   |__/   \______/ \____ xx|________/
   /xxxxxx/xx   /xx /xxxxxx /xxxxxxxx/xxxxxx /xx   \__/xx      /xxxxxxxx/xxxxxxx
  |_  xx_| xxx | xx/xx__  x|__  xx__/xx__  x| xx     | xx     | xx_____| xx__  xx
${YELLOW}    | xx | xxxx| x| xx  \__/  | xx | xx  \ x| xx     | xx     | xx     | xx  \ xx       
    | xx | xx xx x|  xxxxxx   | xx | xxxxxxx| xx     | xx     | xxxxx  | xxxxxxx/
    | xx | xx  xxxx\____  xx  | xx | xx__  x| xx     | xx     | xx__/  | xx__  xx
    | xx | xx\  xxx/xx  \ xx  | xx | xx  | x| xx     | xx     | xx     | xx  \ xx
   /xxxxx| xx \  x|  xxxxxx/  | xx | xx  | x| xxxxxxx| xxxxxxx| xxxxxxx| xx  | xx
  |______|__/  \__/\______/   |__/ |__/  |__|________|________|________|__/  |__/ ${NC}
"

# insert linebreak #
SECTION="Updates/Upgrades"
echo $LineBreak

# start actually doing stuff
apt-get update -y   # assumes you're a super user
apt-get upgrade -y  # assumes you're a super user

# Check if MYSQL installed
if ! command -v mysql --version &> /dev/null
then
  # insert linebreak #
  SECTION="MySQL Installation"
  echo $LineBreak
  
  # installs MySQL
  apt install mysql-server

  # Outputs MYSQL version
  mysql --version

  # complete secure installation
  mysql_secure_installation

  # check if service is running
  systemctl status mysql

  # Output necessary bits:
  printf "Installation now complete to log in press: ${YELLOW}mysql -u root ${NC} to continue"

else
  # insert linebreak #
  SECTION="Already Installed"
  echo $LineBreak
  # Mysql already exists
  echo "MySQL is already installed"
  printf "to log in press: ${YELLOW}mysql -u root ${NC}%b\n"
  echo ""
  fi

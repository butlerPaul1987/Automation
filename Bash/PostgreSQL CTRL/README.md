# PostgreSQL-ctrl.sh script
This was created to ensure there were regular backups of the system taken at set points via cron jobs. Full steps to implement below:

1. Download script via curl:\
if not installed install curl below:
```
sudo apt-get install curl
```
2. Create the directory structure and curl the file:
```
sudo mkdir -p /opt/bin/
sudo curl https://raw.githubusercontent.com/butlerPaul1987/Automation/main/Bash/PostgreSQL%20CTRL/pg_ctrl.sh --output /opt/bin/postgres-ctrl.sh
```
3. Check the content of the file:
```
cat /opt/bin/postgres-ctrl.sh
```
4. Change file permissions and owner (if required)
```
chmod +x /opt/bin/postgres-ctrl.sh
```
5. Run the file with the following examples:
```
sudo /opt/bin/postgres-ctrl.sh --help
```

which will show the following:
```
 USAGE: ./postgres-ctrl.sh ACTION SETTING [RESTOREFILE]

 BACKUP EXAMPLE: ./postgres-ctrl.sh --option backup --host cyient --port 5432
 RESTORE EXAMPLE: ./postgres-ctrl.sh --option restore --host cyient --port 5432 --restore-file /var/backups/postgresql/backup.sql

 ACTION
   -h|--help                          Shows the help output
   -o|--option                        i.e : backup, all-host-backup or restore

 SETTING
   -s |--host                         i.e : Cyient
   -p |--port                         i.e: 5432 (default) or any port running

 RESTOREFILE
  -rf|--restore-file                  Set restore file i.e. /var/backups/postgresql/backup.sql
```
6. Finally run one of the examples, i.e:
```
/opt/bin/postgres-ctrl.sh --option backup --host cyient --port 5432
```


## Error handling:
There are 2 checks performed with the following commands:
```
# Check for missing directory/ .pgpass file/...
! test -d "/var/backups/postgresql" && echo "Missing directory /var/backups/postgresql" && exit 1
! test -f "/root/.pgpass" && echo "Missing .pgpass file - passwordless access won't work" && exit 1
```
These check that both the ```/var/backups/postgresql``` directory exists\
and that the .pgpass file exists as this is how passwordless access is set up.

More on .pgpass here: https://tableplus.com/blog/2019/09/how-to-use-pgpass-in-postgresql.html

# Bash Automation
## InstallMYSQL.sh
This was written because I wanted a way to easily pull a script down to install MYSQL on new installations of Linux (Ubuntu)

### PreReqs:
1. This assumes you're using Ubuntu (Linux) 20.4
2. You need an account with sudo access (if not run the below)
```console
 usermod -aG sudo YourName # where your name is your account name
 ```

### Steps:
1. You need to CURL this file down:
```console
curl "https://raw.githubusercontent.com/butlerPaul1987/Automation/main/Bash/InstallMySQL.sh" -o /home/bash.sh
```
2. Then change the read/write access:
```console
chmod +x /home/bash.sh # this allows the script to be executed
```
3. Finally run the script:
```console
sudo bash /home/bash.sh
```

### What does it do?
This runs in the following steps:
1. Runs an update
2. Runs an upgrade
3. Checks if MySQL is installed
4. If installed it outputs "MySQL is already installed"
5. If not installed it installs

### Example
![This is an image](https://github.com/butlerPaul1987/Automation/blob/main/Bash/example.jpg?raw=true)

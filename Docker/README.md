# Docker-compose.yml
Firstly install the required components:
``` linux
sudo apt-get update -y
sudo apt install docker.io -y && sudo apt install docker-compose -y
```
Then CURL to required directory:
``` linux
curl "https://raw.githubusercontent.com/butlerPaul1987/Boilerplate/main/docker-compose.yml?token=GHSAT0AAAAAABQNPWN3NZT236VS3JC34TWAYO4K74Q" -o docker-compose.yml
```
Finally run the below:
``` linux
sudo docker-compose up
```
You should then be able to navigate to:
http://localhost:8086

to stop docker instance
``` linux
sudo docker-compose stop
```
to start docker instance
``` linux
sudo docker-compose start
```
to completely remove docker instance
``` linux
sudo docker-compose down
```


# Keepalived notes
### **Keepalived VRRP** <br>
- Loadbalancer failover   
- keepalived    
- VRRPv2   
- Virtual Router Redundancy Protocol 

---

### **REFERENCES**
``` ini
[Notes below followed this]:
	https://tecadmin.net/setup-ip-failover-on-ubuntu-with-keepalived/
		
[OTHER]
	https://www.redhat.com/sysadmin/keepalived-basics
	https://packetpushers.net/vrrp-linux-using-keepalived-2/
```
# Process:
Step 1 – Install Required Packages
``` bash
$ sudo apt install linux-headers-$(uname -r)
```
  
Step 2 – Install Keepalived
``` bash
$ sudo apt install keepalived
```

Step 2.1 - Check for available VID, make notes
``` bash
  $ sudo tcpdump -n -nn -i eth0 host 224.0.0.18
	OR
  $ sudo tcpdump proto 112
```
  
Step 3 – Setup Keepalived on LB1.
``` bash
$ sudo nano /etc/keepalived/keepalived.conf
```

Enter the following: (remove comments between **### file start** and **### file end**)
```ini
#### MASTER CONFIG FILE START ####
! Configuration File for keepalived
vrrp_instance VI_1 {
	state MASTER
	interface eth0
	virtual_router_id 115   # change to VID gathered in STEP 2.1
	priority 100
	advert_int 3
	authentication {
	auth_type PASS
	auth_pass hbHB788       # Must match across both servers
	}
virtual_ipaddress {
		192.168.10.50  	# change to the required VIP
	}
}
#### CONFIG FILE END ####
```  

Step 4 – Setup KeepAlived on LB2.
``` bash
$ sudo nano /etc/keepalived/keepalived.conf
```
Enter the following: (remove comments between **### file start** and **### file end**)
```ini
#### BACKUP CONFIG FILE START ####
! Configuration File for keepalived
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 115   # change to VID gathered in STEP 2.1
    priority 101
    advert_int 3
    authentication {
        auth_type PASS      
        auth_pass hbHB788   # Must match across both servers
    }
    virtual_ipaddress {
        192.168.10.50       # change to the required VIP
    }
}
#### CONFIG FILE END #### 
```

Notes:<br>
The configuration directives should be obvious from their naming conventions, but I will walk through each one:
- **vrrp_instance** defines an individual instance of the VRRP protocol running on an interface. I have arbitrarily named this instance VI_1., this can be renamed to make it more identifiable. 
- **state** defines the initial state that the instance should start in. (I.e. backup or master)
- **interface** defines the interface that VRRP runs on. (i.e. eth0, team0, bond0 etc...)
- **virtual_router_id** is the unique identifier that you learned about in the first article of this series. (Step 2.1)
- **priority** is the advertised priority that you learned about in the first article of this series. As you will learn in the next article, priorities can be adjusted at runtime. (100 priority will run as master before 101 etc)
- **advert_int** specifies the frequency that advertisements are sent at (3 second, in this case).
- **authentication** specifies the information necessary for servers participating in VRRP to authenticate with each other. In this case, a simple user/password is defined.
- **virtual_ipaddress** defines the IP addresses (there can be multiple) that VRRP is responsible for.

<br>
1. Priority value will be higher on Master server, It doesn’t matter what you used in state. If your state is MASTER but your priority is lower than the router with BACKUP, you will lose the MASTER state.
<br>2. virtual_router_id should be same on both LB1 and LB2 servers.
<br>3. By default single vrrp_instance support up to 20 virtual_ipaddress. In order to add more addresses you need to add more vrrp_instance

<br>

Step 5 – Start KeepAlived Service
``` bash
$ sudo systemctl start keepalived
$ sudo systemctl status keepalived
$ sudo systemctl enable keepalived
```

  

Step 6 – Check Virtual IPs
``` bash
$ ip addr show eth0
```
 
Step 7 – Verify IP Failover Setup
Shutdown LBL1 && notice LBL2 get Virtual IP


Watch log files to insure its working
``` bash
$ sudo tail -f /var/log/messages    # if centos
$ sudo tail -f /var/log/syslog      # if ubuntu
```
  

TCPDUMP check CRRP traffic polling
```
$ sudo tcpdump -n -nn -i eth0 host 224.0.0.18
	OR
$ sudo tcpdump proto 112
```

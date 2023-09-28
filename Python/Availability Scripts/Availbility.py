#!/usr/bin/python3
import subprocess

# server list
servers = [
    "server1.co.uk",
    "server2.co.uk",
    "server3.co.uk"
]

def check_availability(server):
    try:
        result = subprocess.run(["ping", "-c", "4", server], 
                                capture_output=True, 
                                text=True, 
                                check=True)
        if "64 bytes from" in str(result):
            return f"{server} is reachable"
        else:
            return f"{server} is unreachable..."
    except:
        print("Run failed...")

for server in servers:
    result= check_availability(server)
    print(result)

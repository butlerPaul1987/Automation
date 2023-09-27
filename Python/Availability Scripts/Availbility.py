#!/usr/bin/python3
import subprocess

# server list
servers = [
    "toob.co.uk",
    "portal.toob.co.uk",
    "netadmin.toob.co.uk"
]

def check_availability(server):
    try:
        result = subprocess.run(["ping", "-c", "4", "toob.co.uk"], capture_output=True, text=True, check=True)
        if "64 bytes from" in str(result):
            return f"{server} is reachable"
        else:
            return f"{server} is unreachable..."
    except:
        print("Run failed...")

for server in servers:
    result= check_availability(server)
    print(result)

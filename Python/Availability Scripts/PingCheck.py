#!/usr/bin/python3

import subprocess

# ANSI color codes
RED = "\033[91m"
GREEN = "\033[92m"
RESET = "\033[0m"

def ping_server(server):
    """
    Ping a server and return "OK" if successful, "FAIL" otherwise.
    """
    command = f"ping -c1 {server} > /dev/null 2>&1 && echo OK || echo FAIL"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

def check_server_status(server):
    """
    Check the status of a server and print the result with color coding.
    """
    status = ping_server(server)
    color = GREEN if status == "OK" else RED
    print(f'Checking if "{server}" is up... {color}{status}{RESET}')

def main():
    servers = ["8.8.8.8", "google.co.uk", "www.facebook.co.uk", "hacker.com"]

    print("Server Status Check")
    print("==================")

    for server in servers:
        check_server_status(server)

if __name__ == "__main__":
    main()

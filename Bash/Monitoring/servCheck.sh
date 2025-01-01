#!/bin/bash

function serviceCheck {
    # Print the header only once
    printf "%-20s %-30s\n" "Service" "Status"

    for item in $1
    do
        result=$(systemctl status "$item" >/dev/null 2>&1 && echo "OK" || echo "FAIL")
        printf "%-20s %-30s\n" "$item" "$result"
    done
}

services="cron sshd ssl-cert ufw whoopsie"

serviceCheck "$services"

#!/bin/bash

HOSTNAME=$(hostname)
PORT="22"
SSH_ERROR="SSH error"

sshLogger() {

for i in {1..50}; do
    python3 sshconns.py
 
    if [ $? -ne 0 ]; then
        logger -p user.info "Failed password for root from $HOSTNAME port $PORT ssh2"
    fi
    sleep 5

done

}

# Main script

sshLogger



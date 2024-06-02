#!/usr/bin/env python3

# This script attempts to establish a direct SSH connection to remote hosts using the ssh2 class

from ssh2 import SSH, SSHConfigData, SSHConnectionError

HOSTNAME = ["192.168.20.2", "192.168.20.3", "192.168.20.4", "192.168.20.5", "192.168.20.7", "192.168.10.8"]
USERNAME = "root"
PASSWORD = " "


def failedSSHLogin():

    for host in HOSTNAME:
        try:
            ssh = SSH()
            configs = SSHConfigData(hostname=host)    
            ssh.connect(configs)
            output = ssh.execute("echo 'Connected'")
            print(f"Connected to {host}: {output}")
        except SSHConnectionError as err:
            print(f"SSH error")
            return 1

    return 0


if __name__=="__main__": 

failedSSHLogin()



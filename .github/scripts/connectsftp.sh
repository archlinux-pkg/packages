#!/bin/bash
# ? add ssh public keys
mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
ssh-keyscan -H "$FTP_URI" >> ~/.ssh/known_hosts

# ? connect to sftp and run commands
connectsftp() {
  export SSHPASS="$FTP_PASSWORD"
  sshpass -e sftp -oBatchMode=no -b - "${FTP_USER}@${FTP_URI}"
}

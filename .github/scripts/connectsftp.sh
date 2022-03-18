#!/bin/bash
# add ssh public keys to ssh known hosts
mkdir -p ~/.ssh
ssh-keyscan -H "$FTP_URI" >> ~/.ssh/known_hosts

# connect to sftp and run commands
connectsftp() {
  SSHPASS="$FTP_PASSWORD" sshpass -e sftp -oBatchMode=no -b - "${FTP_USER}@${FTP_URI}"
}

# upload file using rsync, if the file exists it will not be overwritten
upload_file() {
  SSHPASS="$FTP_PASSWORD" sshpass -e rsync -avL --ignore-existing $@ -e ssh "${FTP_USER}@${FTP_URI}:${FTP_CWD}/"
}

# upload file using rsync, if the file exists it will be overwritten
upload_file_overwrite() {
  SSHPASS="$FTP_PASSWORD" sshpass -e rsync -avL $@ -e ssh "${FTP_USER}@${FTP_URI}:${FTP_CWD}/"
}

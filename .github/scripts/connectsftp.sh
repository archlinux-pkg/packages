#!/bin/bash
# ? add ssh public keys
mkdir -p ~/.ssh
ssh-keyscan -H "$FTP_URI" >> ~/.ssh/known_hosts

# ? connect to sftp and run commands
connectsftp() {
  export SSHPASS="$FTP_PASSWORD"
  sshpass -e sftp -oBatchMode=no -b - "${FTP_USER}@${FTP_URI}"
}

upload_file() {
  echo "==> Uploading: $@..."
  export SSHPASS="$FTP_PASSWORD"
  sshpass -e rsync -avL --ignore-existing $@ -e ssh "${FTP_USER}@${FTP_URI}:${FTP_CWD}/"
}

upload_file_overwrite() {\
  echo "==> Uploading: $@..."
  export SSHPASS="$FTP_PASSWORD"
  sshpass -e rsync -avL $@ -e ssh "${FTP_USER}@${FTP_URI}:${FTP_CWD}/"
}

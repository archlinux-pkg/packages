#!/bin/bash
mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
ssh-keyscan -H frs.sourceforge.net >> ~/.ssh/known_hosts

connectsftp() {
  export SSHPASS="$FTP_PASSWORD"
  sshpass -e sftp -oBatchMode=no -b - "$FTP_USER@$FTP_URI"
}

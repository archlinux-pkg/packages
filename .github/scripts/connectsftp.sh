#!/bin/bash
connectsftp() {
  export SSHPASS="$FTP_PASSWORD"
  sshpass -e sftp -oBatchMode=no -b - "$FTP_USER@$FTP_URI"
}

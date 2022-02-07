#!/bin/bash

mkdir queue

conenctsfttp() {
  export SSHPASS="${FTP_PASSWORD}"
  sshpass -e sftp -oBatchMode=no -b - "${FTP_USER}@${FTP_URI}"
}


conenctsfttp << EOF
  cd ${FTP_CWD}/queue
  get * queue
  rm *
EOF

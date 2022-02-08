#!/bin/bash

mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
ssh-keyscan -H frs.sourceforge.net >> ~/.ssh/known_hosts

sudo chown build .

mkdir pkgs

conenctsfttp() {
  export SSHPASS="${FTP_PASSWORD}"
  sshpass -e sftp -oBatchMode=no -b - "${FTP_USER}@${FTP_URI}"
}


conenctsfttp << EOF
  cd ${FTP_CWD}/queue
  get * pkgs
  rm *
  cd ${FTP_CWD}/repo
  get medzikuser.* pkgs
EOF

ls -lah pkgs

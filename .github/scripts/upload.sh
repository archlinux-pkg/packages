#!/bin/bash

mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
ssh-keyscan -H frs.sourceforge.net >> ~/.ssh/known_hosts

conenctsfttp() {
  export SSHPASS="$FTP_PASSWORD"
  sshpass -e sftp -oBatchMode=no -b - "$FTP_USER@$FTP_URI"
}

upload() {
  local file="$1"

  echo "::group::Uploading '${file}'"

  conenctsfttp << EOF
    cd $FTP_CWD/$2
    put ${file}
EOF

  echo "::endgroup::"
}

for file in ./pkgs/*
do
  upload "${file}" "$1"
done

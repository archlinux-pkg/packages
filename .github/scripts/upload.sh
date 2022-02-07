#!/bin/bash
conenctsfttp() {
  export SSHPASS="${FTP_PASSWORD}"
  sshpass -e sftp -oBatchMode=no -b - "${FTP_USER}@${FTP_URI}"
}

upload() {
  echo "::group::Uploading '${file}'"

  conenctsfttp << EOF
    cd ${FTP_CWD}/$1
    put $file
EOF

  echo "::endgroup::"
}

for file in ./pkgs/*
do
  upload "${file}" "$1"
done

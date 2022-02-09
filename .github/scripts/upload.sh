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

#  echo "::group::Uploading '${file}'"

  for (( i=0; i<10; i++ ))
  do
    conenctsfttp << EOF
      cd ${FTP_CWD}
      put ${file}
EOF

    EXIT_STATUS=$?
    echo "exit: $EXIT_STATUS"

    if ! (( $EXIT_STATUS ))
    then
      break
    else
      sleep $(( 5 * (i + 1)))
    fi
  done

#  echo "::endgroup::"
}

for file in ./pkgs/*
do
  upload "${file}" &
done

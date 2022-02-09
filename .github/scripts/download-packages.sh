#!/bin/bash

mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
ssh-keyscan -H frs.sourceforge.net >> ~/.ssh/known_hosts

sudo chown build .

mkdir pkgs

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${DIR}/connectsftp.sh

connectsftp << EOF
  cd ${FTP_CWD}
  get * pkgs
EOF

ls -lah pkgs

#!/bin/bash
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${DIR}/connectsftp.sh

sudo chown build .
mkdir pkgs

connectsftp << EOF
  cd ${FTP_CWD}
  get * pkgs
EOF

ls -lah pkgs

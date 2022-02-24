#!/bin/bash
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${DIR}/connectsftp.sh

sudo chown build .
mkdir pkgs

download_all_files

ls -lah pkgs

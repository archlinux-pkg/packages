#!/bin/bash
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$DIR/connectsftp.sh"

upload() {
  local file="$1"

  for (( i=0; i<10; i++ ))
  do
    echo "==> Uploading: $@..."

    export SSHPASS="$FTP_PASSWORD"
    sshpass -e rsync -avL $@ -e ssh "$FTP_USER@$FTP_URI:$FTP_CWD/../logs"

    EXIT_STATUS=$?
    echo "==> $file | exit code: $EXIT_STATUS"

    if ! (( $EXIT_STATUS ))
    then
      break
    else
      sleep $(( 7 * (i + 1)))
    fi
  done
}

for file in ./logs/*
do
  if [ -f "$file" ]
  then
    upload "$file" &
  fi
done
wait

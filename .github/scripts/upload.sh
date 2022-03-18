#!/bin/bash
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$DIR/connectsftp.sh"

upload() {
  local file="$1"
  local type="$2"

  for (( i=0; i<25; i++ ))
  do
    if [ "$type" != "overwrite" ]
    then
      upload_file "$file"
    else
      upload_file_overwrite "$file"
    fi

    EXIT_STATUS=$?
    echo "==> $file | exit code: $EXIT_STATUS"

    if ! (( $EXIT_STATUS ))
    then
      break
    else
      sleep $(( 5 * (i + 1)))
    fi
  done
}

if [ $# -eq 0 ]
then
  type="normal"
elif [ "$1" == "overwrite" ]
then
  type="overwrite"
fi

for file in ./pkgs/*
do
  if [ -f "$file" ]
  then
    echo "::group::Upload file '$(basename $file)'"
    sleep 0.2
    set -x
    upload "$file" "$type"
    set +x
    echo "::endgroup::"
    sleep 1 # wait a second before upload another file
  fi
done

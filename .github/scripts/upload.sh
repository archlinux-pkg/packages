#!/bin/bash
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${DIR}/connectsftp.sh

upload() {
  local file="$1"
  local type="$2"

  echo "::group::Uploading '${file}'"

  for (( i=0; i<10; i++ ))
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

  echo "::endgroup::"
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
    upload "$file" "$type" &
  fi
done
wait

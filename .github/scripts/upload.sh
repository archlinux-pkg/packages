#!/bin/bash
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$DIR/connectsftp.sh"

FAIL_UPLOAD=()

upload() {
  set -e -u

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
    echo "==> exit code: $EXIT_STATUS"

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
    EXIT_CODE=$?

    if (( $EXIT_CODE ))
    then
      echo "failed to upload file '$(basename $file)'!"

      FAIL_UPLOAD+="$(basename $file)"
    fi

    set +x
    echo "::endgroup::"
    sleep 1 # wait a second before upload another file
  fi
done

#!/bin/bash
upload() {
  local file="$1"

  echo "::group::Uploading '${file}'"

  for (( i=0; i<10; i++ ))
  do
    curl \
      -u "${FTP1_USER}:${FTP1_PASSWORD}" \
      -T "${file}" \
      "${FTP1_URI}"

    EXIT_STATUS=$?
    echo "exit: $EXIT_STATUS"

    if ! (( $EXIT_STATUS ))
    then
      break
    else
      sleep $(( 8 * (i + 1)))
    fi
  done

  echo "::endgroup::"
}

for file in ./pkgs/*
do
  #maxfilesize=94371840
  #filesize=$(stat -c%s "$file")
  #if [[ $filesize -gt $maxfilesize ]]; then
  #    printf "File %s is larger than %d bytes.\n" "$file" $maxfilesize
  #else
  #
  #fi

  upload "${file}" &
  wait
done

#!/bin/bash

upload() {
  local file="${1}"
  local action="${2}"

  for ((i = 0 ; i <= 10 ; i++))
  do
    curl \
      -silent \
      --retry 2 \
      --retry-delay 3 \
      --user "${HTTP_USER}:${HTTP_PASSWORD}" \
      -F "path=@${file}" \
      "${HTTP_URL}/upload?path=/${action}/"

    exit_code=${?}
    echo "${file} | exit code = ${exit_code}"

    if ! (( ${exit_code} ))
    then
      break
    else
      sleep 5
    fi
  done
}

for file in ./pkgdest/*/*.pkg.tar*
do
  upload ${file} "packages"
done

for file in ./pkgfiles/*.txt
do
  upload ${file} "pkgfiles"
done

#!/bin/bash
upload() {
  local FILE="$1"
  local TAG="$2"

  for (( i=0; i<10; i++ ))
  do
    gh release upload --repo 'archlinux-pkg/packages' "${TAG}" "${FILE}"

    EXIT_STATUS=$?
    echo "exit: $EXIT_STATUS"

    if ! (( $EXIT_STATUS ))
    then
      break
    else
      github-release delete --owner 'archlinux-pkg' --repo 'packages' --tag "${TAG}" "${FILE}"

      sleep $(( 8 * (i + 1)))
    fi
  done
}

for FILE in ./pkgs/*
do
  upload "${FILE}" "$1" &
  wait
done

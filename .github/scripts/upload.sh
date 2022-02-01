#!/bin/bash
upload() {
  local FILE="$1"
  local TAG="$2"

  for (( i=0; i<10; i++ ))
  do
    github-release upload --owner 'archlinux-pkg' --repo 'packages' --tag "${TAG}" "${FILE}"

    EXIT_STATUS=$?
    echo "exit: $EXIT_STATUS"

    if ! (( $EXIT_STATUS ))
    then
      break
    else
      github-release delete --owner 'archlinux-pkg' --repo 'packages' --tag "${TAG}" "${FILE}"

      sleep $(( 10 * (i + 1)))
    fi

    github-release delete --owner 'archlinux-pkg' --repo 'packages' --tag "${TAG}" "${FILE}"
  done
}

for FILE in ./pkgs/*
do
  upload "${FILE}" "$1" &
  wait
done

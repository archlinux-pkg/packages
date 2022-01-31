#!/bin/bash

if [[ -d "queue" ]]
then
  for FILE in ./pkgs/*
  do
    echo "::group::Uploading '${FILE}'"

    for (( i=0; i<10; i++ ))
    do
      gh release upload --repo 'archlinux-pkg/packages' 'packages' "${FILE}" --clobber

      EXIT_STATUS=$?
      echo "exit: $EXIT_STATUS"
      
      if ! (( $EXIT_STATUS ))
      then
        break
      else
        github-release delete --owner 'archlinux-pkg' --repo 'packages' --tag 'packages' "${FILE}"

        sleep $(( 10 * (i + 1)))
      fi

      github-release delete --owner 'archlinux-pkg' --repo 'packages' --tag 'packages' "${FILE}"
    done

    echo "::endgroup::"
  done
  
  gh release upload --repo archlinux-pkg/packages packages ./pkgs/* --clobber
fi


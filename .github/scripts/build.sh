#!/bin/bash

CONTAINER_NAME='archlinux-pkg-builder'

if [ -f ./built_packages.txt ]
then
  # echo "Free additional disk space on host..."
  # sudo rm -rf \
  #   /opt/hostedtoolcache \
  #   /usr/share/dotnet \
  #   /usr/share/swift \
  #   /usr/local/lib/android
  # echo "Done!"

  sudo docker run \
    --name ${CONTAINER_NAME} \
    --volume $(pwd):/home/archlinux-pkg \
    ghcr.io/archlinux-pkg/packages:latest \
    /home/archlinux-pkg/.github/scripts/entrypoint.sh
fi

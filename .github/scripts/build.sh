#!/bin/bash

CONTAINER_NAME='archlinux-pkg-builder'

if [ -f ./built_packages.txt ]
then
  # sudo rm -rf \
  #   /opt/hostedtoolcache \
  #   /usr/share/dotnet \
  #   /usr/share/swift \
  #   /usr/local/lib/android

  sudo docker run \
    --name ${CONTAINER_NAME} \
    --volume $(pwd):/home/archlinux-pkg \
    ghcr.io/archlinux-pkg/packages:latest \
    /home/archlinux-pkg/.github/scripts/entrypoint.sh
fi

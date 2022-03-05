#!/bin/bash
#? variables
SRCDIR="$(pwd)"
BUILDDIR="$SRCDIR/builddir"
PKGDEST="$SRCDIR/pkgs"
DOCKER_IMAGE="ghcr.io/archlinux-pkg/packages:latest"

mkdir -p \
  "$BUILDDIR" \
  "$PKGDEST" \

sudo docker run \
  --mount type=bind,source="$BUILDDIR",target=/mnt/builddir \
  --mount type=bind,source="$PKGDEST",target=/mnt/pkgdest \
  --mount type=bind,source="$SRCDIR",target=/mnt/src \
  "$DOCKER_IMAGE" \
  su -c "/mnt/src/build-package.sh $(cat ./built_packages.txt)" build

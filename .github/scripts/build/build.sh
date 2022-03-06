#!/bin/bash
#? variables
SRCDIR="$(pwd)"
BUILDDIR="$SRCDIR/builddir"
PKGDEST="$SRCDIR/pkgs"
DOCKER_IMAGE="ghcr.io/archlinux-pkg/packages:latest"

mkdir -p \
  "$BUILDDIR" \
  "$PKGDEST"

echo "::group::==> Pulling Docker Container..."
sudo docker pull "$DOCKER_IMAGE"
echo "::endgroup::"

sudo docker run \
  --mount type=bind,source="$BUILDDIR",target=/mnt/build \
  --mount type=bind,source="$PKGDEST",target=/mnt/pkgs \
  --mount type=bind,source="$SRCDIR",target=/mnt/src \
  $DOCKER_IMAGE \
  su -c '/mnt/src/build-package.sh' build

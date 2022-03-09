#!/bin/bash
#? variables
SRCDIR="$(pwd)"
BUILDDIR="$SRCDIR/builddir"
LOGDIR="$SRCDIR/logs"
PKGDEST="$SRCDIR/pkgs"
HOMEDIR="$SRCDIR/home"
DOCKER_IMAGE="ghcr.io/archlinux-pkg/packages:latest"

mkdir -p \
  "$BUILDDIR" \
  "$LOGDIR" \
  "$PKGDEST" \
  "$HOMEDIR"

echo "::group::==> Pulling Docker Container..."
sudo docker pull "$DOCKER_IMAGE"
echo "::endgroup::"

sudo docker run \
  --mount type=bind,source="$BUILDDIR",target=/mnt/build \
  --mount type=bind,source="$LOGDIR",target=/mnt/logs \
  --mount type=bind,source="$PKGDEST",target=/mnt/pkgs \
  --mount type=bind,source="$SRCDIR",target=/mnt/src \
  --mount type=bind,source="$HOMEDIR",target=/mnt/home \
  $DOCKER_IMAGE \
  su -c '/mnt/src/build-package.sh' build

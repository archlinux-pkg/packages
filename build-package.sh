#!/bin/bash
# This file is a modified version of: https://github.com/termux/termux-packages/blob/715ce90c53eb9e44c12a5378df907a94522f7df2/build-package.sh

# variables
SRCDIR='/mnt/src'
TEMPDIR="$(mktemp -d -t medzik-aur-XXXXXXXXXX)"
PACKAGES_TO_BUILD_DIR="$TEMPDIR/packages/tobuild"

# makepkg variables
MAKEPKGARGS='--rmdeps --clean --skippgpcheck --noconfirm --nocheck'
export BUILDDIR='/mnt/build'
export PKGDEST='/mnt/pkgs'

export HOME='/mnt/home'

mkdir -p "$PACKAGES_TO_BUILD_DIR"

sudo chown -R $(id -u) /mnt/*

cd "$SRCDIR"

# install yaml parser
wget https://github.com/mikefarah/yq/releases/download/v4.24.2/yq_linux_amd64 -O /tmp/yq
chmod +x /tmp/yq

echo "==> Creating /etc/buildtime..."
echo $(date +"%s") | sudo tee /etc/buildtime

# check the packages to built
while IFS= read -r name
do
  touch "$PACKAGES_TO_BUILD_DIR/$name"
done < "$SRCDIR/built_packages.txt"

# built packages one by one
for FILE in $PACKAGES_TO_BUILD_DIR/*
do
  pkgname="$(basename $FILE)"
  pkgdir="$SRCDIR/packages/$pkgname"

  echo "::group::==> Building '$pkgname'"

  if [ ! -f "$pkgdir/PKGBUILD" ]
  then
    git_repo=$(/tmp/yq '.aur.name' "$pkgdir/auto-update.yaml")
    git_repo="https://aur.archlinux.org/$git_repo.git"
    commit=$(/tmp/yq '.aur.commit' "$pkgdir/auto-update.yaml")

    eval "$custom_vars"

    mv "$pkgdir" "$pkgdir.old"

    git clone "$git_repo" "$pkgdir"

    cd "$pkgdir"

    git reset --hard "$commit"

    code=$?

    if [ $code != 0 ]
    then
      echo "$pkgname | exit code: $code" >> "$SRCDIR/fail_built.txt"
      continue
    fi
  fi

  cd "$pkgdir"

  echo "==> Sychronizing dependencies..."
  for (( i=0; i<15; i++ ))
  do
    sudo pacman -Sy
    makepkg --nobuild --noextract --syncdeps --noconfirm

    EXIT_STATUS=$?

    if ! (( $EXIT_STATUS ))
    then
      break
    else
      sleep 2
      echo "==> Sychronizing dependencies... (attempt $i)"
    fi
  done

  SOURCE_DATE_EPOCH=$(cat /etc/buildtime) makepkg $MAKEPKGARGS

  code=$?

  if [ $code != 0 ]
  then
    echo "$pkgname | exit code: $code"
    echo "$pkgname | exit code: $code" >> "$SRCDIR/fail_built.txt"
  fi

  echo "::endgroup::"
done

if [ -f "$SRCDIR/fail_built.txt" ]
then
  printf "\n\nFailed to build:\n"

  cat --number "$SRCDIR/fail_built.txt"

  exit 1
fi

#!/bin/bash

set -e -o pipefail -u

SRCDIR=/home/archlinux-pkg

export PKGDEST="$SRCDIR/pkgs"

declare -a PACKAGE_LIST=()

if [ "$#" -lt 1 ]
then
  printf "./build-package.sh: type package to build\n"
  exit 2
fi

while (($# >= 1))
do
  case "$1" in
    -*)
      printf "./build-package.sh: illegal option '$1'\n"
      exit 2
      ;;
    *)
      PACKAGE_LIST+=("$1")
      ;;
  esac
	shift 1
done

for ((i=0; i<${#PACKAGE_LIST[@]}; i++))
do
  cd ${SRCDIR}/packages/${PACKAGE_LIST[i]}

  time makepkg --sync --rmdeps --clean --skippgpcheck --noconfirm
done

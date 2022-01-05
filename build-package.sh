#!/bin/bash

SRCDIR=/home/archlinux-pkg

export PKGDEST="$SRCDIR/pkgs"

declare -a PACKAGE_LIST=()

declare -a BUILD_FAIL=()

if [ "$#" -lt 1 ]
then
  printf "./build-package.sh: type package name to build\n"
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

  code=$?

  if [ ${code} != 0 ]
  then
    BUILD_FAIL+=("${PACKAGE_LIST[i]} | exit code: ${code}")
  fi
done

for ((i=0; i<${#BUILD_FAIL[@]}; i++))
do
  echo "Failed to build: ${i}) ${BUILD_FAIL[i]} | exit code: ${code}"
done

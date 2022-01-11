#!/bin/bash

ROOT_DIR=$(pwd)

SRCDIR=/home/archlinux-pkg

export PKGDEST="$SRCDIR/pkgs"

declare -a PACKAGE_LIST=()

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

  sudo pacman -Sy

  makepkg --sync --rmdeps --clean --skippgpcheck --noconfirm

  code=$?

  if [ ${code} != 0 ]
  then
    echo "${PACKAGE_LIST[i]} | exit code: ${code}" >> ${ROOT_DIR}/fail_built.txt
  fi
done

if [ -f ${ROOT_DIR}/fail_built.txt ]
then
  printf "\n\nFailed to build:\n"

  cat --number ${ROOT_DIR}/fail_built.txt

  exit 1
fi

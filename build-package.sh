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
  if [ -f "${SRCDIR}/packages/${PACKAGE_LIST[i]}/_clone" ]
  then
    custom_vars=$(
      . "${SRCDIR}/packages/${PACKAGE_LIST[i]}/_clone"
      echo "git_repo=${_git};"
      echo "commit=${_commit};"
    )

    eval "${custom_vars}"

    mv "${SRCDIR}/packages/${PACKAGE_LIST[i]}/_clone" "${SRCDIR}/packages/${PACKAGE_LIST[i]}.old"

    git clone "${git_repo}" "${SRCDIR}/packages/${PACKAGE_LIST[i]}/_clone"

    git reset --hard ${commit}
  fi

  cd "${SRCDIR}/packages/${PACKAGE_LIST[i]}"

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

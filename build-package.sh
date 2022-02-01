#!/bin/bash

ROOT_DIR=$(pwd)
SRCDIR=$(pwd)

BUILD_DATE=$(date +%F-%T)

mkdir -p "${SRCDIR}/pkgfiles"

declare -a PACKAGE_LIST=()

export BUILDDIR="${SRCDIR}/build_dir"

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
  pkgname="${PACKAGE_LIST[i]}"
  pkgdir="${SRCDIR}/packages/${pkgname}"

  if [ -f "${pkgdir}/git.sh" ]
  then
    custom_vars=$(
      . "${pkgdir}/git.sh"
      echo "git_repo=${_git};"
      echo "commit=${_commit};"
    )

    eval "${custom_vars}"

    mv "${pkgdir}" "${pkgdir}.old"

    git clone "${git_repo}" "${pkgdir}"

    cd "${pkgdir}"

    git reset --hard ${commit}

    code=$?

    if [ ${code} != 0 ]
    then
      echo "${PACKAGE_LIST[i]} | exit code: ${code}" >> "${ROOT_DIR}/fail_built.txt"
      continue
    fi
  fi

  cd "${pkgdir}"

  sudo pacman -Sy

  mkdir -p "${SRCDIR}/pkgdest/${pkgname}"

  PKGDEST="${SRCDIR}/pkgdest/${pkgname}" makepkg --sync --rmdeps --clean --skippgpcheck --noconfirm

  code=$?

  if [ ${code} != 0 ]
  then
    echo "${PACKAGE_LIST[i]} | exit code: ${code}" >> "${ROOT_DIR}/fail_built.txt"
  else
    for f in "${SRCDIR}"/pkgdest/"${pkgname}"/*
    do
      echo "$(basename ${f})" >> "${SRCDIR}/pkgfiles/${pkgname}-${BUILD_DATE}.txt"
    done
  fi
done

if [ -f "${ROOT_DIR}/fail_built.txt" ]
then
  printf "\n\nFailed to build:\n"

  cat --number "${ROOT_DIR}/fail_built.txt"

  exit 1
fi

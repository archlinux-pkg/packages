#!/bin/bash
#? This file is a modified version of: https://github.com/termux/termux-packages/blob/715ce90c53eb9e44c12a5378df907a94522f7df2/build-package.sh
ROOT_DIR=$(pwd)
SRCDIR=$(pwd)

mkdir -p "${SRCDIR}/pkgfiles"

declare -a PACKAGE_LIST=()

export BUILDDIR="${SRCDIR}/build_dir"

echo "==> Creating /etc/buildtime..."
echo $(date +"%s") | sudo tee /etc/buildtime

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

  echo "::group::Building '${pkgname}'"

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

  mkdir -p "${SRCDIR}/pkgs"

  SOURCE_DATE_EPOCH=$(cat /etc/buildtime) PKGDEST="${SRCDIR}/pkgs" makepkg --sync --rmdeps --clean --skippgpcheck --noconfirm

  code=$?

  if [ ${code} != 0 ]
  then
    echo "${PACKAGE_LIST[i]} | exit code: ${code}" >> "${ROOT_DIR}/fail_built.txt"
  fi

  echo "::endgroup::"
done

if [ -f "${ROOT_DIR}/fail_built.txt" ]
then
  printf "\n\nFailed to build:\n"

  cat --number "${ROOT_DIR}/fail_built.txt"

  exit 1
fi

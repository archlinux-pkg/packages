#!/bin/bash
#? This file is a modified version of: https://github.com/termux/termux-packages/blob/715ce90c53eb9e44c12a5378df907a94522f7df2/build-package.sh
ROOT_DIR=$(pwd)
SRCDIR=$(pwd)

mkdir -p "${SRCDIR}/pkgfiles"

declare -a PACKAGE_LIST=()

export BUILDDIR="${SRCDIR}/build_dir"

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${DIR}/connectsftp.sh

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

delete() {
  local file="$1"

  for (( i=0; i<10; i++ ))
  do
    connectsftp << EOF
      cd ${FTP_CWD}
      rm ${file}-[0-9]*
EOF

    EXIT_STATUS=$?
    echo "exit: $EXIT_STATUS"

    if ! (( $EXIT_STATUS ))
    then
      break
    else
      sleep $(( 5 * (i + 1)))
    fi
  done
}

for ((i=0; i<${#PACKAGE_LIST[@]}; i++))
do
  delete "${PACKAGE_LIST[i]}" &
done

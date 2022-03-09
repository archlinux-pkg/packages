#!/bin/bash
#? This file is a modified version of: https://github.com/termux/termux-packages/blob/715ce90c53eb9e44c12a5378df907a94522f7df2/build-package.sh

#? variables
SRCDIR='/mnt/src'

#? makepkg variables
export BUILDDIR='/mnt/build'
export PKGDEST='/mnt/pkgs'

#? set home dir
export HOME='/mnt/home'

declare -a PACKAGE_LIST=()

sudo chown -R $(id -u) /mnt/*

cd "$SRCDIR"

echo "==> Creating /etc/buildtime..."
echo $(date +"%s") | sudo tee /etc/buildtime

while IFS= read -r line
do
  PACKAGE_LIST+=("$line")
done < "$SRCDIR/built_packages.txt"

for ((i=0; i<${#PACKAGE_LIST[@]}; i++))
do
  pkgname="${PACKAGE_LIST[i]}"
  pkgdir="$SRCDIR/packages/$pkgname"

  echo "::group::==> Building '$pkgname'"

  if [ -f "$pkgdir/git.sh" ]
  then
    custom_vars=$(
      . "$pkgdir/git.sh"
      echo "git_repo=${_git};"
      echo "commit=${_commit};"
    )

    eval "$custom_vars"

    mv "$pkgdir" "$pkgdir.old"

    git clone "$git_repo" "$pkgdir"

    cd "$pkgdir"

    git reset --hard "$commit"

    code=$?

    if [ $code != 0 ]
    then
      echo "${PACKAGE_LIST[i]} | exit code: $code" >> "$SRCDIR/fail_built.txt"
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

  SOURCE_DATE_EPOCH=$(cat /etc/buildtime) makepkg --sync --rmdeps --clean --skippgpcheck --noconfirm

  code=$?

  if [ $code != 0 ]
  then
    echo "${PACKAGE_LIST[i]} | exit code: $code" >> "$SRCDIR/fail_built.txt"
  fi

  echo "::endgroup::"
done

if [ -f "$SRCDIR/fail_built.txt" ]
then
  printf "\n\nFailed to build:\n"

  cat --number "$SRCDIR/fail_built.txt"

  exit 1
fi

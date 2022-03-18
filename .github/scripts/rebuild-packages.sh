#!/bin/bash
# This file is a modified version of: https://github.com/termux/termux-packages/blob/715ce90c53eb9e44c12a5378df907a94522f7df2/scripts/bin/update-packages

# variables
BASEDIR="$(pwd)"
TEMPDIR="$(mktemp -d -t medzik-aur-XXXXXXXXXX)"

# create temporary dir for git clone
mkdir -p "$TEMPDIR/git"

rebuild_package() {
  PKGDIR="$1"
  REBUILDTYPE="$2"
  PKGNAME=$(basename $1)

  # check if the package is from AUR
  if [ -f "$PKGDIR/git.sh" ]
  then
    custom_vars=$(
      . "$PKGDIR/git.sh"
      echo "rebuild=$rebuild;"
    )

    rebuild='null'; # Overwrite variables with 'null' value
    eval "$custom_vars"

    # trigger rebuild packge
    if [ "$auto_update_rebuild" == "$REBUILDTYPE" ]
    then
      echo "{\"packages\":\"$PKGNAME\"}" | gh workflow run build.yml --json
      EXIT_CODE=$?

      echo "Rebuild was triggered for the package '$PKGNAME'"

      return $EXIT_CODE
    fi

  # check if the package exists
  elif [ -f "$PKGDIR/PKGBUILD" ]
  then
    build_vars=$(
      set +e +u
      . "$PKGDIR/PKGBUILD"
      echo "auto_update=$_auto_update;"
      echo "auto_update_rebuild=$_auto_update_rebuild;"
    )

    auto_update='null'; auto_update_rebuild='null'; # Overwrite variables with 'null' value
    eval "$build_vars"

    # ignore the package if auto-update isn't enabled
    if [ "$auto_update" != "true" ]
    then
      return 0
    fi

    # trigger rebuild packge
    if [ "$auto_update_rebuild" == "$REBUILDTYPE" ]
    then
      gh workflow run build.yml -f packages="$PKGNAME"
      EXIT_CODE=$?

      echo "Rebuild was triggered for the package '$PKGNAME' | exit code $EXIT_CODE"

      return $EXIT_CODE
    fi
  fi
}

if [ -z "$1" ]
then
  echo "No argument supplied"

  exit 1
fi

for PKGDIR in "$BASEDIR"/packages/* "$BASEDIR"/long-build/*
do
  rebuild_package "$PKGDIR" "$1"
  EXIT_CODE=$?

  if (( $EXIT_CODE ))
  then
    echo "failed to trigger rebuild package '$(basename $PKGDIR)'!"
  fi
done

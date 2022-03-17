#!/bin/bash
# This file is a modified version of: https://github.com/termux/termux-packages/blob/715ce90c53eb9e44c12a5378df907a94522f7df2/scripts/bin/update-packages

# variables
BASEDIR="$(pwd)"
TEMPDIR="$(mktemp -d -t medzik-aur-XXXXXXXXXX)"

# create temporary dir for git clone
mkdir -p "$TEMPDIR/git"

update_package() {
  set -e -u

  PKGDIR="$1"
  PKGNAME=$(basename $1)

  # check if the package is from AUR
  if [ -f "$PKGDIR/git.sh" ]
  then
    custom_vars=$(
      . "$PKGDIR/git.sh"
      echo "git_repo=$_git;"
      echo "git_commit=$_commit;"
    )

    git_repo='null'; git_commit='null' # Overwrite variables with 'null' value
    eval "$custom_vars"

    # clone repository from AUR
    git clone "$git_repo" "$TEMPDIR/git/$PKGNAME" --depth 1 #&> /dev/null

    # check the latest commit of the package in AUR
    commit_long='null'; commit_short='null' # Overwrite variables with 'null' value
    cd "$TEMPDIR/git/$PKGNAME"
    commit_long=$(git log -n 1 --pretty=format:"%H")
    commit_short=$(git log -n 1 --pretty=format:"%h")
    cd "$BASEDIR"

    rm -rf "$TEMPDIR/git/$PKGNAME"

    # check if there is a newer commit, if so, change it to the package file 'git.sh'
    if [ "$git_commit" != "$commit_long" ]
    then
      sed -i "s|^\(_commit=\)\(.*\)\$|\1'$commit_long'|g" "$PKGDIR/git.sh"

      # commit and push changes
      git add "$PKGDIR"
      git diff-index --quiet HEAD || git commit -m "update '$PKGNAME' to AUR commit '$commit_short'"
    fi

    return 0
  fi

  # check if the package exists
  if [ -f "$PKGDIR/PKGBUILD" ]
  then
    build_vars=$(
      set +e +u
      . "$PKGDIR/PKGBUILD"
      echo "auto_update=$_auto_update;"
      echo "auto_update_git=$_auto_update_git;"
      echo "auto_update_github_tag=$_auto_update_github_tag;"
      echo "auto_update_npm=$_auto_update_npm;"
      echo "pkg_tag=\"${_ver}\";"
      echo "pkg_repo=\"${_repo}\";"
      echo "pkg_npm=\"${_npm}\";"
    )

    auto_update='null'; auto_update_git='null'; auto_update_github_tag='null'; auto_update_npm='null'; pkg_tag='null'; pkg_repo='null'; pkg_npm='null' # Overwrite variables with 'null' value
    eval "$build_vars"

    # ignore the package if auto-update isn't enabled
    if [ "$auto_update" != "true" ]
    then
      return 0
    fi

    version='null'; latest_tag='null' # Overwrite variables with 'null' value

    # ignore the package if it is built from git (master branch)
    if [ "$auto_update_git" == true ]
    then
      return 0

    # check latest version from github by tags
    elif [ "$auto_update_github_tag" == true ]
    then
      latest_tag=$(curl --location --silent -H "Authorization: token $GITHUB_API_TOKEN" "https://api.github.com/repos/$pkg_repo/tags" | jq -r '.[0].name')

      # Translate "_" into ".": some packages use underscores to seperate
      # version numbers, but we require them to be separated by dots.
      version=${latest_tag//_/.}

      # Remove leading 'v' or 'r'
      version=${version#[v,r]}

      # Translate "-" into ".": pacman does not support - in pkgver
      version=${version//-/.}

    # check latest version from npmjs.org
    elif [ "$auto_update_npm" == true ]
    then
      latest_tag=$(curl --location --silent "https://unpkg.com/$pkg_npm/package.json" | jq -r ".version")
      version=$latest_tag

    # check latest version from github by releases
    elif [ ! -f "$PKGDIR/_version" ]
    then
      latest_tag=$(curl --silent --location -H "Authorization: token $GITHUB_API_TOKEN" "https://api.github.com/repos/$pkg_repo/releases/latest" | jq -r .tag_name)

      # If the github api returns error
      if [ -z "$latest_tag" ] || [ "$latest_tag" = "null" ]
      then
        echo "Error: failed to get the latest release tag for '$PKGNAME'. GitHub API returned 'null' which indicates that no releases available"
        return 1
      fi

      # Translate "_" into ".": some packages use underscores to seperate
      # version numbers, but we require them to be separated by dots.
      version=${latest_tag//_/.}

      # Remove leading 'v' or 'r'
      version=${version#[v,r]}

      # Translate "-" into ".": pacman does not support - in pkgver
      version=${version//-/.}

    # check version from custom function using '_version' file
    elif [ -f "$PKGDIR/_version" ]
    then
      custom_vars=$(
        . "$PKGDIR/_version"
        echo "latest_tag=${_ver};"
        echo "version=\"${pkgver}\";"
      )

      eval "$custom_vars"
    fi

    # if the version is incorrect
    if [[ -z "$latest_tag" || "$latest_tag" = "null" || -z "$version" || "$version" = "null" ]]
    then
      echo "Error: failed to get the latest version for '$PKGNAME'. Version returned 'null'."
      return 1
    fi

    # version comparison
    if [ "$(echo -e "$pkg_tag\n$latest_tag" | sort -V | head -n 1)" != "$latest_tag" ]
    then
      echo "Updating '$PKGNAME' to '$latest_tag'.."

      # update the version in the package files
      sed -i "s|^\(_ver=\)\(.*\)\$|\1$latest_tag|g" "$PKGDIR/PKGBUILD"
      sed -i "s|^\(pkgver=\)\(.*\)\$|\1$version|g" "$PKGDIR/PKGBUILD"
      # change pkgrel to '1'
      git diff-index --quiet HEAD || sed -i "s/^\(pkgrel=\)\(.*\)\$/\11/g" "$PKGDIR/PKGBUILD"

      echo "==> Updating pkgsum..."
      cd "$PKGDIR"
      chown -R build .
      su -c 'updpkgsums' build
      cd "$BASEDIR"

      git add "$PKGDIR/PKGBUILD"
      git commit -m "update '$PKGNAME' to '$version'"
    fi
  fi
}

for PKGDIR in "$BASEDIR"/packages/* "$BASEDIR"/long-build/*
do
  echo "::group::==> Updating package '$(basename $PKGDIR)'..."
  sleep 0.2
  set -x

  update_package "$PKGDIR"
  EXIT_CODE=$?

  if ! (( $EXIT_CODE ))
  then
    git pull --rebase &> /dev/null
    git push
  else
    echo "failed to update package '$(basename $PKGDIR)'!"
  fi

  set +x
  echo "::endgroup::"
  sleep 0.2
done

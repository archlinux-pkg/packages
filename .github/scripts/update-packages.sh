#!/bin/bash
#? This file is a modified version of: https://github.com/termux/termux-packages/blob/715ce90c53eb9e44c12a5378df907a94522f7df2/scripts/bin/update-packages
BASEDIR="$(pwd)"
TEMPDIR="$(mktemp -d -t medzik-aur-XXXXXXXXXX)"

# Temporary dir for git clone
mkdir -p "${TEMPDIR}/git"

for pkg_dir in "${BASEDIR}"/packages/* "${BASEDIR}"/long-build/*
do
  pkg_name=$(basename ${pkg_dir})

  if [ ! -f "${pkg_dir}/git.sh" ]
  then
    build_vars=$(
      set +e +u
      . "${pkg_dir}/PKGBUILD"
      echo "auto_update=${_auto_update};"
      echo "auto_update_git=${_auto_update_git};"
      echo "pkg_tag=\"${_ver}\";"
      echo "pkg_repo=\"${_repo}\";"
    )

    eval "${build_vars}"

    # Ignore packages that have auto-update disabled.
    if [ "${auto_update}" != "true" ]
    then
      continue
    fi

    # Check the latest version from github
    if [ "${auto_update_git}" == true ]
    then
      git clone "https://github.com/${pkg_repo}.git" "${TEMPDIR}/git/${pkg_name}" 2> /dev/null

      cd "${TEMPDIR}/git/${pkg_name}"
      latest_tag=$(git log -1 --date=short --pretty=format:"%H")
      version=$(git log -1 --date=short --pretty=format:%cd_%ct | sed -r 's/-/./g')
      cd ${BASEDIR}

      rm -rf "${TEMPDIR}/git/${pkg_name}"
    elif [ ! -f "${pkg_dir}/_version" ]
    then
      latest_tag=$(curl --silent --location -H "Authorization: token ${GITHUB_API_TOKEN}" "https://api.github.com/repos/${pkg_repo}/releases/latest" | jq -r .tag_name)

      # If the github api returns error
      if [ -z "${latest_tag}" ] || [ "${latest_tag}" = "null" ]
      then
        echo "Error: failed to get the latest release tag for '${pkg_dir}'. GitHub API returned 'null' which indicates that no releases available."
        continue
      fi

      # Translate "_" into ".": some packages use underscores to seperate
      # version numbers, but we require them to be separated by dots.
      version=${latest_tag//_/.}

      # Remove leading 'v' or 'r'
      version=${version#[v,r]}

      # Translate "-" into ".": pacman does not support - in pkgver
      version=${version//-/.}
    else
      custom_vars=$(
        . "${pkg_dir}/_version"
        echo "latest_tag=${_ver};"
        echo "version=\"${pkgver}\";"
      )

      eval "${custom_vars}"
    fi

    # If the github api returns error
    if [ -z "${latest_tag}" ] || [ "${latest_tag}" = "null" ]
    then
      echo "Error: failed to get the latest version for '${pkg_name}'. Version returned 'null'."
      continue
    fi

    # We have no better choice for comparing versions.
    if [ "$(echo -e "${pkg_tag}\n${latest_tag}" | sort -V | head -n 1)" != "${latest_tag}" ]
    then
      echo "Updating '${pkg_name}' to '${latest_tag}'"

      sed -i "s|^\(_ver=\)\(.*\)\$|\1${latest_tag}|g" "${pkg_dir}/PKGBUILD"
      sed -i "s|^\(pkgver=\)\(.*\)\$|\1${version}|g" "${pkg_dir}/PKGBUILD"
      git diff-index --quiet HEAD || sed -i "s/^\(pkgrel=\)\(.*\)\$/\11/g" "${pkg_dir}/PKGBUILD"

      echo "==> Updating pkgsum..."
      cd "$pkg_dir"
      chown -R build .
      su -c 'updpkgsums' build
      cd "$BASEDIR"

      git add "$pkg_dir/PKGBUILD"
      git commit -m "update '$pkg_name' to '$version'"
      git pull --rebase 2> /dev/null
      git push 2> /dev/null
    fi
  else
    custom_vars=$(
      . "${pkg_dir}/git.sh"
      echo "git_repo=${_git};"
    )

    eval "${custom_vars}"

    # Get latest commat from AUR
    git clone "${git_repo}" "${TEMPDIR}/git/${pkg_name}" --depth 1 2> /dev/null

    cd "${TEMPDIR}/git/${pkg_name}"
    _commit_long="$(git log -n 1 --pretty=format:"%H")"
    _commit_short="$(git log -n 1 --pretty=format:"%h")"
    cd "${BASEDIR}"

    sed -i "s|^\(_commit=\)\(.*\)\$|\1${_commit_long}|g" "${pkg_dir}/git.sh"

    rm -rf "${TEMPDIR}/git/${pkg_name}"

    git add ${pkg_dir}
    git diff-index --quiet HEAD || git commit -m "update '${pkg_name}' to AUR commit '${_commit_short}'"
    git pull --rebase > /dev/null
    git push 2> /dev/null
  fi
done

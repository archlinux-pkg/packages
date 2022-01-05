#!/bin/bash

BASEDIR=$(pwd)

for pkg_dir in "${BASEDIR}"/packages/*
do
  if [ ! -f "${pkg_dir}/.git" ]
  then
    build_vars=$(
      set +e +u
      . "${pkg_dir}/PKGBUILD"
      echo "auto_update=${_auto_update};"
      echo "pkg_tag=\"${_ver}\";"
      echo "pkg_repo=\"${_repo}\";"
    )

    eval "$build_vars"

    # Ignore packages that have auto-update disabled.
    if [ "${auto_update}" != "true" ]
    then
      continue
    fi

    if [ ! -f "${pkg_dir}/_version" ]
    then
      latest_tag=$(curl --silent --location -H "Authorization: token ${GITHUB_API_TOKEN}" "https://api.github.com/repos/${pkg_repo}/releases/latest" | jq -r .tag_name)

      # If the github api returns error
      if [ -z "$latest_tag" ] || [ "${latest_tag}" = "null" ]
      then
        echo "Error: failed to get the latest release tag for '${pkg_dir}'. GitHub API returned 'null' which indicates that no releases available."
        continue
      fi

      ver_a=${latest_tag#[v,r]}
      version=${ver_a//-/_}
    else
      custom_vars=$(
        . "${pkg_dir}/_version"
        echo "latest_tag=${_ver};"
        echo "version=\"${pkgver}\";"
      )

      eval "$custom_vars"
    fi

    if [ -z "$latest_tag" ] || [ "${latest_tag}" = "null" ]
    then
      echo "Error: failed to get the latest version for '${pkg_dir}'. Version returned 'null'."
      continue
    fi

    if [ "$pkg_tag" != "$latest_tag" ]
    then
      pkg_name=$(basename ${pkg_dir})

      echo "Updating '${pkg_name}' to '${latest_tag}'."

      sed -i "s|^\(_ver=\)\(.*\)\$|\1${latest_tag}|g" "${pkg_dir}/PKGBUILD"
      sed -i "s|^\(pkgver=\)\(.*\)\$|\1${version}|g" "${pkg_dir}/PKGBUILD"
      git diff-index --quiet HEAD || sed -i "s/^\(pkgrel=\)\(.*\)\$/\11/g" "${pkg_dir}/PKGBUILD"

      git add ${pkg_dir}
      git commit -m "update '${pkg_name}' to '${latest_tag}'"
      git pull --rebase
      git push
    fi
  else
    pkg_name=$(basename ${pkg_dir})

    cd "${pkg_dir}"

    git fetch > /dev/null
    git reset --hard origin/master > /dev/null

    git add ${pkg_dir}
    git commit -m "update submodule '${pkg_name}'"
    git pull --rebase
    git push
  fi
done

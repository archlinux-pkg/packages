#!/bin/bash
if [ "${github_event}" != "workflow_dispatch" ]
then
  BASE_COMMIT=$(jq --raw-output .pull_request.base.sha "${GITHUB_EVENT_PATH}")
  OLD_COMMIT=$(jq --raw-output .commits[0].id "${GITHUB_EVENT_PATH}")
  HEAD_COMMIT=$(jq --raw-output .commits[-1].id "${GITHUB_EVENT_PATH}")
  if [ "${BASE_COMMIT}" = "null" ]
  then
    if [ "${OLD_COMMIT}" = "${HEAD_COMMIT}" ]
    then
      # * Single-commit push.
      echo "Processing commit: ${HEAD_COMMIT}"
      CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r "${HEAD_COMMIT}")
    else
      # * Multi-commit push.
      OLD_COMMIT="${OLD_COMMIT}~1"
      echo "Processing commit range: ${OLD_COMMIT}..${HEAD_COMMIT}"
      CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r "${OLD_COMMIT}" "${HEAD_COMMIT}")
    fi
  else
    # * Pull requests.
    echo "Processing pull request #$(jq --raw-output .pull_request.number "${GITHUB_EVENT_PATH}"): ${BASE_COMMIT}..HEAD"
    CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r "${BASE_COMMIT}" "HEAD")
  fi
fi

mkdir pkgs

if [ "${github_event}" != "workflow_dispatch" ]
then
  # Process tag '%ci:no-build' that may be added as line to commit message.
  # Forces CI to cancel current build with status 'passed'.
  if grep -qiP '^\s*%ci:no-build\s*$' <(git log --format="%B" -n 1 "HEAD")
  then
    echo "[!] Force exiting as tag '%ci:no-build' was applied to HEAD commit message."
    exit 0
  fi

  # Parse changed files and identify new packages and deleted packages.
  # Create lists of those packages that will be passed to upload job for
  # further processing.
  while read -r file
  do
    if [ -d ${file} ]
    then
      file="${file}/PKGBUILD"
    fi

    # * This file does not belong to a package, so ignore it
    if ! [[ ${file} == packages/* ]]
    then
      continue
    fi

    if [[ ${file} =~ ^packages/([.a-z0-9+-]*)/.*$ ]]
    then
      # * package, check if it was deleted or updated
      pkg=${BASH_REMATCH[1]}
      if [ ! -d "packages/${pkg}" ]; then
        echo "${pkg}" >> ./deleted_packages.txt
      else
        echo "${pkg}" >> ./built_packages.txt
      fi
    fi
  done<<<${CHANGED_FILES}
else
  for pkg in ${github_inputs_packages}
  do
    echo "${pkg}" >> ./built_packages.txt
  done
fi

# ! Fix so that lists do not contain duplicates
if [ -f ./built_packages.txt ]
then
  uniq ./built_packages.txt > ./built_packages.txt.tmp
  mv ./built_packages.txt.tmp ./built_packages.txt
fi

if [ -f ./deleted_packages.txt ]
then
  uniq ./deleted_packages.txt > ./deleted_packages.txt.tmp
  mv ./deleted_packages.txt.tmp ./deleted_packages.txt
fi

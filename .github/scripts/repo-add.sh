#!/bin/bash

if [[ -d "queue" ]]
then
  mv queue/* packages/

  cd packages
  repo-add --new --verify --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz *.pkg.tar.xz
fi

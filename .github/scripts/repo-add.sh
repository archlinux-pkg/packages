#!/bin/bash

if [[ -d "queue" ]]
then
  mv queue/* pkgs/

  cd pkgs
  repo-add --verify --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz *.pkg.tar.xz
fi

#!/bin/bash

if [[ -f queue ]]
then
  mkdir pkgs
  mv queue/* pkgs/

  cd pkgs
  repo-add --remove --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz *.pkg.tar.xz
fi

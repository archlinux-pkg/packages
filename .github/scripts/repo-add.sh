#!/bin/bash
cd pkgs

rm -f medzikuser.*

repo-add --remove --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz *.pkg.tar.xz

find . -type f -not -name 'medzikuser.*' -delete

#!/bin/bash
TEMPDIR="$(mktemp -d -t medzik-aur-XXXXXXXXXX)"

for file in pkgs/*
do
  if [ "$file" != medzikuser.* ]
  then
    touch "$TEMPDIR/$(basename ${file})"
  fi
done

cd pkgs

rm -f medzikuser.*

repo-add --new --remove --prevent-downgrade --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz *.pkg.tar.xz

cd ..

diff -q pkgs "$TEMPDIR" | grep 'Only in' | grep "$TEMPDIR" | awk '{print $4}' > diff.txt

find pkgs -type f -not -name 'medzikuser.*' -delete

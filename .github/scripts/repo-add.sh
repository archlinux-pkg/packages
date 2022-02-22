#!/bin/bash
mkdir pkgs_all

for file in pkgs/*
do
  if [ "$file" != medzikuser.* ]
  then
    touch "pkgs_all/$(basename ${file})"
  fi
done

cd pkgs

rm -f medzikuser.*

FILES=()

for file in $(ls *.pkg.tar.xz | sort -V)
do
  FILES+=("$file")
done

echo "1: $FILES\n\n\n\n"
echo "3: ${FILES[@]}"

repo-add --new --remove --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz ${FILES[@]}

cd ..

diff -q pkgs pkgs_all | grep 'Only in' | grep pkgs_all | awk '{print $4}' > diff.txt

find pkgs -type f -not -name 'medzikuser.*' -delete

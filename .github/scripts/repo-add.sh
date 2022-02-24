#!/bin/bash
TEMPDIR="$(mktemp -d -t medzik-aur-XXXXXXXXXX)"

for file in pkgs/*
do
  touch "$TEMPDIR/$(basename $file)"
done

cd pkgs

#rm -f medzikuser.*

repo-add --new --remove --prevent-downgrade --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz *.pkg.tar.xz

cd ..

# check what files have been deleted and save the list to `diff.txt`
diff -q pkgs "$TEMPDIR" | grep 'Only in' | grep "$TEMPDIR" | awk '{print $4}' > diff.txt

# delete all files that are not `medzikuser.*` (database files)
find pkgs -type f -not -name 'medzikuser.*' -delete

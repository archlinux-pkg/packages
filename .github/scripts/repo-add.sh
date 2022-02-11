#!/bin/bash

mkdir pkgs_all

for file in pkgs/*
do
  touch "pkgs_all/$(basename ${file})"
done

cd pkgs

rm -f medzikuser.*

repo-add --remove --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz *.pkg.tar.xz

cd ..

diff -q pkgs pkgs_all | grep 'Only in' | grep pkgs_all | awk '{print $4}'

echo asdddddd

deleted=$(diff -q pkgs pkgs_all | grep 'Only in' | grep pkgs_all | awk '{print $4}')

echo ${deleted}

find pkgs -type f -not -name 'medzikuser.*' -delete

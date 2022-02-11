#!/bin/bash
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${DIR}/delete.sh

mkdir pkgs_all

for file in pkgs/*
do
  touch "pkgs_all/$(basename ${file})"
done

cd pkgs

rm -f medzikuser.*

repo-add --remove --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz *.pkg.tar.xz

cd ..

deleted=$(diff -q pkgs pkgs_all | grep 'Only in' | grep pkgs_all | awk '{print $4}')

su -c '${DIR}/delete.sh ${deleted}' build

find pkgs -type f -not -name 'medzikuser.*' -delete

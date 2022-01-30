#!/bin/bash

cd /home/archlinux-pkg

mv queue/* packages/*

cd packages

sudo repo-add --new --remove --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz *.pkg.tar.xz

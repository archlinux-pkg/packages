#!/bin/bash

mv queue/* packages/

cd packages
repo-add --new --remove --verify --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz *.pkg.tar.xz

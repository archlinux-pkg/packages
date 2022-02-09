#!/bin/bash
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${DIR}/connectsftp.sh

cd pkgs
mkdir tmp

rm -f medzikuser.*

for file in *
do
  touch "tmp/${file}"
done

repo-add --remove --sign --key 7A6646A6C14690C0 medzikuser.db.tar.xz *.pkg.tar.xz
find . -type f -not -name 'medzikuser.*' -delete

mv tmp ..

cd ..

diff -r tmp pkgs | grep 'Only in' | grep tmp | awk '{print $4}' > delete_files.txt

while IFS= read -r line; do
  connectsftp << EOF
    cd ${FTP_CWD}
    rm ${line}
EOF
done < delete_files.txt

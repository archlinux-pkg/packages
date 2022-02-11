#!/bin/bash
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${DIR}/connectsftp.sh

delete() {
  local file="$1"

#  echo "::group::Uploading '${file}'"

  for (( i=0; i<10; i++ ))
  do
    connectsftp << EOF
      cd ${FTP_CWD}
      rm ${file}
EOF

    EXIT_STATUS=$?
    echo "exit: $EXIT_STATUS"

    if ! (( $EXIT_STATUS ))
    then
      break
    else
      sleep $(( 5 * (i + 1)))
    fi
  done

#  echo "::endgroup::"
}

for file in $@
do
  delete "${file}"
done
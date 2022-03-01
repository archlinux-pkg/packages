#!/bin/bash
sshpass -e ssh "${SSHUSER}@${SSHHOST}" create
sshpass -e ssh "${SSHUSER}@${SSHHOST}" '~/update-repo.sh'

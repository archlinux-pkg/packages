#!/bin/bash
mkdir -p ~/.ssh
ssh-keyscan -H "$SSHHOST" >> ~/.ssh/known_hosts

sshpass -e ssh "${SSHUSER}@${SSHHOST}" create
sshpass -e ssh "${SSHUSER}@${SSHHOST}" '~/update-repo.sh'

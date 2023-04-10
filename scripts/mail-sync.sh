#!/usr/bin/env bash

# If one command fails (probably network connectivity issues), we don't need to execute the rest of them
set -e

yad --notification --image mail-inbox --listen &
PID=$!

mbsync -aq
~/Documents/scripts/notmuch-run.sh
~/Documents/scripts/mail-queue-run.sh
~/Documents/scripts/aliases-gen.sh
~/Documents/scripts/mail-notify.sh

kill "$PID"

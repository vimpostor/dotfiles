#!/usr/bin/env bash

# If one command fails (probably network connectivity issues), we don't need to execute the rest of them
set -e

mbsync -aq
~/Documents/scripts/mail-notify.sh
~/Documents/scripts/aliases-gen.sh
~/Documents/scripts/mail-queue-run.sh
~/Documents/scripts/notmuch-run.sh

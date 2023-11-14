#!/usr/bin/env bash
# Pipe a Gerrit "newchange" patchset notification email into this script and provide an argument to perform automated review actions
# For help see: ssh $URL gerrit review --help

set -e

COMMIT="$(grep -m1 '^X-Gerrit-Commit: [[:alnum:]]\{40\}$' | grep -o '[[:alnum:]]\{40\}$')"
URL="$(git remote get-url origin | sed 's#^\(ssh\|git\|https?\)://##' | sed 's#/.*##' | sed 's/^.*@//' | sed 's/:[0-9]\+$//')"
ssh "$URL" gerrit review "$@" "$COMMIT"

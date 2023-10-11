#!/usr/bin/env bash

set -e

# Install post-commit hook for "Change-Id: ",
# that is needed by Gerrit to track different patchsets for the same review
scp -pqO "scp://$(git remote get-url origin | sed 's#^\(ssh\|git\|https?\)://##' | sed 's#/.*##')"/hooks/commit-msg .git/hooks/commit-msg
echo 'Successfully setup .git/hooks/commit-msg to generate "Change-Id:" headers'

#!/usr/bin/env sh

set -e

OUTPUT="$(notmuch new --quiet 2>&1)"
printf "$(printf "$OUTPUT" | grep -v 'Ignoring non-mail file')"

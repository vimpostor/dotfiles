#!/usr/bin/env sh

set -e

OUTPUT="$(notmuch new --quiet 2>&1)"
printf "%s" "$(printf "%s" "$OUTPUT" | grep -v 'Ignoring non-mail file')"

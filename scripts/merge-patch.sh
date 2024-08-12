#!/usr/bin/env bash
# This script detects various kinds of automatic mails and tries to apply the patch depending on the platform

set -e

MAILFILE="$(mktemp)"
cat - > "$MAILFILE"

# Gerrit patchset
if grep -q '^X-Gerrit-Commit: [[:alnum:]]\{40\}$' "$MAILFILE"; then
	# submit the Gerrit patch
	~/Documents/scripts/gerrit-review.sh -s < "$MAILFILE"
else
	# just apply the patch as mail
	git am < "$MAILFILE"
fi

rm "$MAILFILE"

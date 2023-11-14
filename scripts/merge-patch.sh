#!/usr/bin/env bash
# This script detects various kinds of automatic mails and tries to apply the patch depending on the platform

set -e

MAIL="$(mktemp)"
cat - > "$MAIL"

# Gerrit patchset
if grep -q '^X-Gerrit-Commit: [[:alnum:]]\{40\}$' "$MAIL"; then
	# submit the Gerrit patch
	~/Documents/scripts/gerrit-review.sh -s < "$MAIL"
else
	# just apply the patch as mail
	git am < "$MAIL"
fi

rm "$MAIL"

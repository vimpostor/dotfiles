#!/usr/bin/env bash
# This script detects various kinds of automatic mails and dispatches automatic background jobs for them

set -e

# Decodes MIME RFC 2047 to UTF8
function decode() {
	ESCAPED="${*//\"/}"
	ESCAPED="${ESCAPED//\@/\\\@}"
	DECODER="use utf8; print decode(\"MIME-Header\", \"$ESCAPED\")"
	DECODED="$(echo "" | perl -CS -MEncode -ne "$DECODER" || echo 'Parse Error')"
}

MAILFILE="$(mktemp)"
cat - > "$MAILFILE"

SUBJECT="$(grep -A1 -m1 '^Subject:' "$MAILFILE" | grep -E '^Subject: |^\s.' | sed 's/^Subject://' |  sed 's/^\s*\|\s*$//g' | tr '\n' ' ' | sed 's/ $//')"
decode "$SUBJECT"
SUBJECT="$DECODED"
SENDER="$(grep -E -m1 '^From: ' "$MAILFILE" | sed 's/From: //')"
decode "$SENDER"
SENDER="$DECODED"
SENDER_NICK="${DECODED%% <*>}"

# AUR out of date notification
if [ "$SENDER" = 'notify@aur.archlinux.org' ] && [[ "$SUBJECT" == 'AUR Out-of-date Notification for '* ]]; then
	~/Documents/scripts/auto-build-pkg.sh < "$MAILFILE"
# Github PR
elif [[ "$SENDER" == *'notifications@github.com'* ]] && [[ "$SUBJECT" =~ ^\[.*/.*\]\ .*\ \(PR\ \#[0-9]*\) ]]; then
	~/Documents/scripts/auto-build-github.sh < "$MAILFILE"
# Gerrit patchset
elif [[ "$SUBJECT" == *'Change in '* ]] && grep -q '^X-Gerrit-Change-Number: [0-9]\+$' "$MAILFILE"; then
	~/Documents/scripts/auto-build-gerrit.sh < "$MAILFILE"
# No matches
else
	gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.Notify 'Job Dispatcher' 0 'script-error' 'Dispatched job failed' 'Could not find any matching job rule.' '[]' '{"desktop-entry": <"org.wezfurlong.wezterm">, "urgency": <"0">}' 5000 >/dev/null
fi

rm "$MAILFILE"

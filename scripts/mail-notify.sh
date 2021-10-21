#!/usr/bin/env bash
# Usage: MAILDIR_INBOX=/path/to/inbox mail-notify.sh

set -e

# do not notify about individual messages, but summarize as soon as this number of new messages is reached
SUMMARY_THRESHOLD=5
MSG_CACHE="$HOME/.cache/mail-notify.cache"

if [[ -z "$MAILDIR_INBOX" ]]; then
	# use default maildir
	MAILDIR_INBOX="$(find "$HOME/.local/share/mail/" -type d -name 'INBOX' | head -1)"
fi
MAILDIR_NEW="$MAILDIR_INBOX/new"
if ! [[ -d "$MAILDIR_NEW" ]]; then
	echo "Error: $MAILDIR_NEW is not a directory!"
	exit 1
fi
# create cache if it doesn't exist
if ! [[ -f "$MSG_CACHE" ]]; then
	touch "$MSG_CACHE"
fi

# Decodes MIME RFC 2047 to UTF8
function decode() {
	DECODER="print decode(\"MIME-Header\", \"${*//\"/}\")"
	DECODED="$(echo "" | perl -CS -MEncode -ne "$DECODER" || echo 'Parse Error')"
}

# sends a notification with title and body
function notify() {
	gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.Notify 'mutt' 0 'mail-message' "$1" "$2" '[]' '{"desktop-entry": <"org.kde.konsole">, "category": <"email.arrived">}' 5000
}

COUNT=$(ls -b1 "$MAILDIR_NEW" | wc -l)
if [[ "$COUNT" -eq 0 ]]; then
	# no new messages
	echo 'No new messages.'
elif [[ "$COUNT" -lt "$SUMMARY_THRESHOLD" ]]; then
	# send a notification for each message
	for MSG in "$MAILDIR_NEW"/*; do
		# only notify if we haven't already for this message
		if ! grep -Fq "$(basename "$MSG")" "$MSG_CACHE"; then
			SENDER="$(grep -E '^From: ' "$MSG" | sed 's/From: //')"
			decode "$SENDER"
			PARSED_SENDER="$(echo "$DECODED"| sed 's/ <.*>//g')"
			SUBJECT="$(grep -EA1 '^Subject:' "$MSG" | grep -E '^Subject: |^\s.' | sed 's/^Subject://' |  sed 's/^\s*\|\s*$//g')"
			decode "$SUBJECT"
			notify "$PARSED_SENDER" "$DECODED"
		fi
	done
else
	# print a summary (digest) message
	notify "You have new mail!" "$COUNT new messages."
fi

# create cache
ls -b1 "$MAILDIR_NEW" > "$MSG_CACHE"

#!/usr/bin/env bash
# Usage: MAILDIR_INBOX=/path/to/inbox mail-notify.sh

set -e

# do not notify about individual messages, but summarize as soon as this number of new messages is reached
SUMMARY_THRESHOLD=5
MSG_CACHE="/tmp/.mail-notify-$UID.cache"

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
touch "$MSG_CACHE"

# Decodes MIME RFC 2047 to UTF8
function decode() {
	ESCAPED="${*//\"/}"
	ESCAPED="${ESCAPED//\@/\\\@}"
	DECODER="use utf8; print decode(\"MIME-Header\", \"$ESCAPED\")"
	DECODED="$(echo "" | perl -CS -MEncode -ne "$DECODER" || echo 'Parse Error')"
}

# sends a notification with title and body
function notify() {
	NOTIFICATION_ID="$(gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.Notify 'mutt' 0 'mail-message' "${1//</&lt;}" "${2//</&lt;}" '[]' '{"desktop-entry": <"org.kde.konsole">, "category": <"email.arrived">}' 5000 2>/dev/null | grep -Eo 'uint32\s[[:digit:]]+'| cut -d' ' -f2)"
}

# dismisses a notification
function notify-delete() {
	if [ -n "$1" ]; then
		gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.CloseNotification "$1" >/dev/null
	fi
}

# $MAILDIR_NEW \ $MSG_CACHE
NEW_MSGS="$(grep -Fvf <(cut -d' ' -f1 "$MSG_CACHE"| sed '/^$/d') <(ls -b1 "$MAILDIR_NEW"))" || true
COUNT="$(printf "%s" "$NEW_MSGS"| grep -c '^')" || true
if [[ "$COUNT" -lt "$SUMMARY_THRESHOLD" ]]; then
	# send a notification for each message
	while IFS= read -r MSG_ID; do
		if [ -z "$MSG_ID" ]; then
			continue
		fi
		MSG="$MAILDIR_NEW/$MSG_ID"
		SENDER="$(grep -E -m1 '^From: ' "$MSG" | sed 's/From: //')"
		decode "$SENDER"
		SENDER_NICK="${DECODED%% <*>}"
		SUBJECT="$(grep -A1 -m1 '^Subject:' "$MSG" | grep -E '^Subject: |^\s.' | sed 's/^Subject://' |  sed 's/^\s*\|\s*$//g' | tr '\n' ' ' | sed 's/ $//')"
		decode "$SUBJECT"
		notify "$SENDER_NICK" "$DECODED"
		# create cache
		echo "$MSG_ID $NOTIFICATION_ID" >> "$MSG_CACHE"
	done <<< "$NEW_MSGS"
else
	# show a summary (digest) message
	notify "You have new mail!" "$COUNT new messages."
	# create cache, only append the notification ID to the first msg id
	echo "${NEW_MSGS%%$'\n'*} $NOTIFICATION_ID" >> "$MSG_CACHE"
	echo "${NEW_MSGS#*$'\n'}"| sed 's/$/ /' >> "$MSG_CACHE"
fi

# delete previous notifications for messages that have been read by now and rebuild cache without them
CACHED_MSGS=()
while IFS= read -r LINE; do
	MSG_ID="${LINE%% *}"
	NOTIFICATION_ID="${LINE##* }"
	if [ -f "$MAILDIR_NEW/$MSG_ID" ]; then
		CACHED_MSGS+=("$MSG_ID $NOTIFICATION_ID")
	else
		notify-delete "$NOTIFICATION_ID"
	fi
done < "$MSG_CACHE"
printf "%s\n" "${CACHED_MSGS[@]}" > "$MSG_CACHE"

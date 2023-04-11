#!/usr/bin/env bash

set -e

# do not notify about individual messages, but summarize as soon as this number of new messages is reached
SUMMARY_THRESHOLD=5
MSG_CACHE="/tmp/.mail-notify-$UID.cache"

# create cache if it doesn't exist
touch "$MSG_CACHE"

# sends a notification with title and body
function notify() {
	NOTIFICATION_ID="$(gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.Notify 'mutt' 0 'mail-message' "$1" "${2//</&lt;}" '[]' '{"desktop-entry": <"org.wezfurlong.wezterm">, "category": <"email.arrived">}' 5000 2>/dev/null | grep -Eo 'uint32\s[[:digit:]]+'| cut -d' ' -f2)"
}

# dismisses a notification
function notify-delete() {
	if [ -n "$1" ]; then
		gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.CloseNotification "$1" >/dev/null
	fi
}

UNREAD_MSGS="$(notmuch search --format=text --output=messages -- tag:unread 'path:maildir/INBOX/**')"
# $UNREAD_MSGS \ $MSG_CACHE
NEW_MSGS="$(printf "%s" "$UNREAD_MSGS" | grep -Fvf <(cut -d' ' -f1 "$MSG_CACHE"| sed '/^$/d'))" || true
COUNT="$(printf "%s" "$NEW_MSGS"| grep -c '^')" || true
if [[ "$COUNT" -lt "$SUMMARY_THRESHOLD" ]]; then
	# send a notification for each message
	while IFS= read -r MSG_ID; do
		if [ -z "$MSG_ID" ]; then
			continue
		fi
		HEADERS="$(notmuch show --format=json --entire-thread=false --part=0 "$MSG_ID" | jq '.headers')"
		SENDER="$(printf "%s" "$HEADERS" | jq -r '.From')"
		SENDER_NICK="${SENDER%% <*>}"
		SUBJECT="$(printf "%s" "$HEADERS" | jq -r '.Subject')"
		notify "$SENDER_NICK" "$SUBJECT"
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
	if echo "$UNREAD_MSGS" | grep -qF "$MSG_ID"; then
		CACHED_MSGS+=("$MSG_ID $NOTIFICATION_ID")
	else
		notify-delete "$NOTIFICATION_ID"
	fi
done < "$MSG_CACHE"
printf "%s\n" "${CACHED_MSGS[@]}" > "$MSG_CACHE"

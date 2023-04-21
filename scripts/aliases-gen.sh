#!/usr/bin/env bash

MUTT_CACHE="$HOME/.cache/mutt"
MUTT_ALIASES_CACHE="$MUTT_CACHE/aliases"
LAST_TIMESTAMP_CACHE="$MUTT_CACHE/last-timestamp"
MAIL_BLACKLIST=('notifications@github.com' '.*not?-?reply.*')

set -e
# Do not expand * to itself when nothing matches
shopt -s nullglob

# we use associative arrays to get free deduplication
declare -A CONTACTS

mkdir -p "$MUTT_CACHE"
touch "$MUTT_ALIASES_CACHE"
# read old cache
while IFS= read -r LINE; do
	KEY="${LINE%$'\t'*}"
	VALUE="${LINE##*$'\t'}"
	if [ -n "$KEY" ]; then
		CONTACTS["$KEY"]="$VALUE"
	fi
done < "$MUTT_ALIASES_CACHE"
# read last timestamp
LAST_TIMESTAMP="$(cat "$LAST_TIMESTAMP_CACHE" 2>/dev/null)" || LAST_TIMESTAMP=""

QUERY='path:maildir/INBOX/**'
if [ -n "$LAST_TIMESTAMP" ]; then
	QUERY="date:@$LAST_TIMESTAMP.. $QUERY"
else
	echo 'Indexing for the first time, this may take a while... (subsequent runs will be substantially faster)'
fi
MAILS="$(notmuch search --format=text --output=messages --sort=oldest-first -- "$QUERY")"
# parse new messages
for MAIL_ID in $MAILS; do
	if [ -z "$MAIL_ID" ]; then
		continue
	fi

	MAIL="$(notmuch show --format=json --entire-thread=false --part=0 "$MAIL_ID")"
	TIMESTAMP="$(echo "$MAIL" | jq -r '.timestamp')"
	SUBJECT="$(echo "$MAIL" | jq -r '.headers.Subject')"
	ADDRESSES="$(notmuch address --output=sender --output=recipients "$MAIL_ID")"

	# iterate over newline separated addresses
	while IFS= read -r COMPLETE_ADDRESS; do
		if [ -z "$COMPLETE_ADDRESS" ]; then
			continue
		fi

		if [[ "$COMPLETE_ADDRESS" =~ '<' ]]; then
			LONG_NAME="${COMPLETE_ADDRESS%% <*}"
			MAIL_ADDRESS="$(echo "$COMPLETE_ADDRESS" | grep -Eo '<\S*>')"
		else
			LONG_NAME=''
			MAIL_ADDRESS="$(echo "$COMPLETE_ADDRESS" | grep -Eo '\S*')"
		fi
		# check if address is in blacklist
		BLACKLISTED=0
		for BLACK in "${MAIL_BLACKLIST[@]}"; do
			if [[ "$MAIL_ADDRESS" =~ $BLACK ]]; then
				BLACKLISTED=1
				break
			fi
		done

		if [ "$BLACKLISTED" -eq 0 ]; then
			CONTACTS["$MAIL_ADDRESS\t$LONG_NAME"]="$SUBJECT"
		fi
	done <<< "$ADDRESSES"
done
echo "$TIMESTAMP" > "$LAST_TIMESTAMP_CACHE"

ALIASES=''
for CONTACT in "${!CONTACTS[@]}"; do
	ALIASES="$ALIASES\n$CONTACT\t${CONTACTS["$CONTACT"]}"
done
mkdir -p "$MUTT_CACHE"
echo -e "$ALIASES" | sed '/^$/d' > "$MUTT_ALIASES_CACHE"

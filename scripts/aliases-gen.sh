#!/usr/bin/env bash
# This script parses all addresses from a mail folder and adds them as aliases
# Usage: MAILDIR=/path/to/inbox aliases-gen.sh

MUTT_CACHE="$HOME/.cache/mutt"
MUTT_ALIASES_CACHE="$MUTT_CACHE/aliases"
LAST_ID_CACHE="$MUTT_CACHE/last-id"
MAIL_BLACKLIST=("notifications@github.com")

set -e
# Do not expand * to itself when nothing matches
shopt -s nullglob

if [[ -z "$MAILDIR" ]]; then
	# use default maildir
	MAILDIR="$(find "$HOME/.local/share/mail/" -type d -name 'INBOX' | head -1)"
fi
MAILDIR_CUR="$MAILDIR/cur"

# canonicalize all addresses
for ((i = 0; i < ${#MAIL_BLACKLIST[@]}; i++)); do
	MAIL_BLACKLIST[i]="<${MAIL_BLACKLIST[i]}>"
done

# Decodes MIME RFC 2047 to UTF8
function decode() {
	ESCAPED="${*//\"/}"
	ESCAPED="${ESCAPED//\@/\\\@}"
	DECODER="use utf8; print decode(\"MIME-Header\", \"$ESCAPED\")"
	DECODED="$(echo "" | perl -CS -MEncode -ne "$DECODER" || echo 'Parse Error')"
}

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
# read last id
LAST_ID="$(cat "$LAST_ID_CACHE" 2>/dev/null)" || LAST_ID=""

# parse new messages
for MAIL in "$MAILDIR_CUR"/*; do
	if [ ! "$MAIL" \> "$LAST_ID" ]; then
		# skip, this one was cached already
		continue
	fi
	FROM="$(grep -EA1 -m1 '^From:' "$MAIL" | grep -E '^From: |^\s+.' | sed 's/^From://' | sed 's/^\s*\|\s*$//g' | tr '\n' ' ' | sed 's/^\s*\|\s*$//g')"
	TO="$(grep -EA1 -m1 '^To:' "$MAIL" | grep -E '^To: |^\s+.' | sed 's/^To://' | sed 's/^\s*\|\s*$//g' | tr '\n' ' ' | sed 's/^\s*\|\s*$//g')"
	ADDRESSES="$FROM, $TO"
	# iterate over ", " separated addresses
	while [ -n "$ADDRESSES" ]; do
		# Parse the next address and skip this mail if we get an error
		NEXT="$(echo "$ADDRESSES" | grep -Eo '^[^<]*<\S*>[, ]?')" || NEXT="$(echo "$ADDRESSES" | grep -Eo '^\S+@\S+[, ]?')" || ADDRESSES=''
		if [ -n "$NEXT" ]; then
			COMPLETE_ADDRESS="${NEXT%, }"
			if [[ "$COMPLETE_ADDRESS" =~ '<' ]]; then
				LONG_NAME="${COMPLETE_ADDRESS%%<*}"
				decode "$LONG_NAME"
				LONG_NAME="${DECODED//\"/\\\"}"
				LONG_NAME="$(echo "$LONG_NAME" | sed 's/\s*$//')"
				MAIL_ADDRESS="$(echo "$NEXT" | grep -Eo '<\S*>')"
			else
				LONG_NAME=''
				MAIL_ADDRESS="$(echo "$NEXT" | grep -Eo '\S*')"
			fi
			SUBJECT="$(grep -A1 -m1 '^Subject:' "$MAIL" | grep -E '^Subject: |^\s.' | sed 's/^Subject://' |  sed 's/^\s*\|\s*$//g' | tr '\n' ' ' | sed 's/ $//')"
			decode "$SUBJECT"
			# skip if address is in blacklist
			if [[ ! " ${MAIL_BLACKLIST[*]} " =~ " ${MAIL_ADDRESS} " ]]; then
				CONTACTS["$MAIL_ADDRESS\t$LONG_NAME"]="$DECODED"
			fi
		fi
		ADDRESSES="${ADDRESSES##"$NEXT"}"
	done
done
echo "$MAIL" > "$LAST_ID_CACHE"

ALIASES=''
for CONTACT in "${!CONTACTS[@]}"; do
	ALIASES="$ALIASES\n$CONTACT\t${CONTACTS["$CONTACT"]}"
done
mkdir -p "$MUTT_CACHE"
echo -e "$ALIASES" > "$MUTT_ALIASES_CACHE"

#!/usr/bin/env bash
# This script parses all To: addresses from a Sent mail folder and adds them as aliases
# Usage: MAILDIR_SENT=/path/to/inbox aliases-gen.sh

set -e
# Do not expand * to itself when nothing matches
shopt -s nullglob

if [[ -z "$MAILDIR_SENT" ]]; then
	# use default maildir
	MAILDIR_SENT="$(find "$HOME/.local/share/mail/" -type d -name 'Sent' | head -1)"
fi
MAILDIR_CUR="$MAILDIR_SENT/cur"

# Decodes MIME RFC 2047 to UTF8
function decode() {
	DECODER="use utf8; print decode(\"MIME-Header\", \"${*//\"/}\")"
	DECODED="$(echo "" | perl -CS -MEncode -ne "$DECODER" || echo 'Parse Error')"
}

# we use associative arrays to get free deduplication
declare -A CONTACTS

for MAIL in "$MAILDIR_CUR"/*; do
	TO="$(grep -EA1 '^To:' "$MAIL" | grep -E '^To: |^\s+.' | sed 's/^To://' | sed 's/^\s*\|\s*$//g' | tr '\n' ' ')"
	# iterate over ", " separated To: addresses
	while [ -n "$TO" ]; do
		# Parse the next address and skip this mail if we get an error
		NEXT="$(echo "$TO" | grep -Eo '^[^<]*<\S*>(, )?')" || TO=''
		if [ -n "$NEXT" ]; then
			COMPLETE_ADDRESS="${NEXT%, }"
			LONG_NAME="${COMPLETE_ADDRESS%%<*}"
			decode "$LONG_NAME"
			LONG_NAME="${DECODED//\"/\\\"}"
			LONG_NAME="$(echo "$LONG_NAME" | sed 's/\s*$//')"
			MAIL_ADDRESS="$(echo "$NEXT" | grep -Eo '<\S*>')"
			CONTACTS["$LONG_NAME $MAIL_ADDRESS"]=1
		fi
		TO="${TO##"$NEXT"}"
	done
done

INDEX=0
ALIASES=''
for CONTACT in "${!CONTACTS[@]}"; do
	ALIASES="$ALIASES\nalias $INDEX $CONTACT"
	INDEX=$((INDEX + 1))
done
echo -e "$ALIASES" > ~/.config/mutt/aliases

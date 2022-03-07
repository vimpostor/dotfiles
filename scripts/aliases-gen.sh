#!/usr/bin/env bash
# This script parses all To: addresses from a Sent mail folder and adds them as aliases
# Usage: MAILDIR_SENT=/path/to/inbox aliases-gen.sh

MUTT_CACHE="$HOME/.cache/mutt"

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
	TO="$(grep -EA1 -m1 '^To:' "$MAIL" | grep -E '^To: |^\s+.' | sed 's/^To://' | sed 's/^\s*\|\s*$//g' | tr '\n' ' ')"
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
			SUBJECT="$(grep -A1 -m1 '^Subject:' "$MAIL" | grep -E '^Subject: |^\s.' | sed 's/^Subject://' |  sed 's/^\s*\|\s*$//g' | tr '\n' ' ' | sed 's/ $//')"
			decode "$SUBJECT"
			CONTACTS["$MAIL_ADDRESS\t$LONG_NAME"]="$DECODED"
		fi
		TO="${TO##"$NEXT"}"
	done
done

ALIASES=''
for CONTACT in "${!CONTACTS[@]}"; do
	ALIASES="$ALIASES\n$CONTACT\t${CONTACTS["$CONTACT"]}"
done
mkdir -p "$MUTT_CACHE"
echo -e "$ALIASES" > "$MUTT_CACHE/aliases"

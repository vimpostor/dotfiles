#!/usr/bin/env bash

ARGS="hs:"
HELPMSG='This script copies a directory structure containing PDF files to a Remarkable and automatically imports it into the library.

Usage:
remarkable-sync.sh -s HOST /path/to/sync

-h: Show help
-s HOST: SSH host name

If no trailing argument is provided, the current directory is synced.
'
CACHE_DIR="/tmp/.remarkable/xochitl"
SSH_HOST=""

set -e
uuid() {
	UUID="$(uuidgen -s --namespace '@dns' --name "$(printf '%s' "$*" | sha256sum)")"
}

fileinfo() {
	# pad with trailing zeroes for milliseconds
	CREATED="$(stat -c '%W' "$*")000"
	MODIFIED="$(stat -c '%Y' "$*")000"
	BASENAME="$(basename "$*")"
}

while getopts $ARGS OPT; do
	case $OPT in
	h)
		printf "%s" "$HELPMSG"
		exit 0
		;;
	s)
		SSH_HOST="$OPTARG"
		;;
	:)
		echo "Error: -$OPT requires an argument"
		exit 1
		;;
	?)
		echo "Error Unknown option -$OPT"
		exit 1
		;;
	esac
done
shift $((OPTIND -1))

SYNC_DIR="$(readlink -f "${*:-.}")"
TARGET_DIR="/home/root/.local/share/remarkable"
mkdir -p "$CACHE_DIR"

# first create folders
while IFS= read -r -d '' D; do
	fileinfo "$D"
	D="${D#"$SYNC_DIR/"}"
	PARENT="$(dirname "$D")"
	if [ "$PARENT" = "." ]; then
		PARENT=""
	else
		uuid "$PARENT"
		PARENT="$UUID"
	fi
	uuid "$D"
	cat > "$CACHE_DIR/$UUID.metadata" <<EOF
{
	"createdTime": "$CREATED",
	"lastModified": "$MODIFIED",
	"new": false,
	"parent": "$PARENT",
	"pinned": false,
	"source": "",
	"type": "CollectionType",
	"visibleName": "$BASENAME"
}
EOF
done < <(find "$SYNC_DIR" -mindepth 1 -type d -print0)

while IFS= read -r -d '' PDF; do
	fileinfo "$PDF"
	F="${PDF#"$SYNC_DIR/"}"
	uuid "$(dirname "$F")"
	PARENT="$UUID"
	uuid "$F"
	cat > "$CACHE_DIR/$UUID.metadata" <<EOF
{
	"createdTime": "$CREATED",
	"deleted": false,
	"lastModified": "$MODIFIED",
	"lastOpened": "",
	"lastOpenedPage": 0,
	"metadatamodified": false,
	"modified": false,
	"new": false,
	"parent": "$PARENT",
	"pinned": false,
	"source": "",
	"synced": false,
	"type": "DocumentType",
	"version": 0,
	"visibleName": "${BASENAME%.pdf}"
}
EOF
	cat > "$CACHE_DIR/$UUID.content" << EOF
{
	"coverPageNumber": -1,
	"documentMetadata": {},
	"dummyDocument": false,
	"extraMetadata": {},
	"fileType": "pdf",
	"fontName": "",
	"lineHeight": -1,
	"pageCount": 0,
	"textScale": 1
}
EOF
	cp "$PDF" "$CACHE_DIR/$UUID.pdf"
	mkdir -p "$CACHE_DIR/$UUID"
	mkdir -p "$CACHE_DIR/$UUID.thumbnails"
	echo "Blank" > "$CACHE_DIR/$UUID.pagedata"
done < <(find "$SYNC_DIR" -type f -name '*.pdf' -print0)

if [ -n "$SSH_HOST" ]; then
	scp -r "$CACHE_DIR" "root@$SSH_HOST:$TARGET_DIR"
	ssh "root@$SSH_HOST" 'systemctl restart xochitl'
fi

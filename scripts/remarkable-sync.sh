#!/usr/bin/env bash

ARGS="hp:s:"
HELPMSG='This script copies a directory structure containing PDF files to a Remarkable and automatically imports it into the library.

Usage:
remarkable-sync.sh -s HOST -p Sheets /path/to/sync

-h: Show help
-p PREFIX: Directory to use for target install
-s HOST: SSH host name

If no trailing argument is provided, the current directory is synced.
'
CACHE_DIR="/tmp/.remarkable/xochitl"
SSH_HOST=""
PREFIX=""
PREFIX_DIRS=()

set -e
uuid() {
	UUID="$(uuidgen -s --namespace '@dns' --name "$(printf '%s' "$*" | sha256sum)")"
}

fileinfo() {
	# pad with trailing zeroes for milliseconds
	CREATED="$(stat -c '%W' "$*" 2>/dev/null || date +%s)000"
	MODIFIED="$(stat -c '%Y' "$*" 2>/dev/null || date +%s)000"
	BASENAME="$(basename "$*")"
}

# first argument is the folder to create, second arg determines whether to add the prefix
folder() {
	fileinfo "$1"
	D="${1#"$SYNC_DIR/"}"
	if [ "$2" = 1 ]; then
		D="$PREFIX$D"
	fi
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
}

while getopts $ARGS OPT; do
	case $OPT in
	h)
		printf '%s' "$HELPMSG"
		exit 0
		;;
	p)
		PREFIX="$OPTARG"
		while [ "$OPTARG" != '.' ]; do
			PREFIX_DIRS+=("$OPTARG")
			OPTARG="$(dirname "$OPTARG")"
		done
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
rm -rf "$CACHE_DIR"
mkdir -p "$CACHE_DIR"

# first create folders
for D in "${PREFIX_DIRS[@]}"; do
	folder "$D" 0
done

if [ -n "$PREFIX" ]; then
	PREFIX="$PREFIX/"
fi

while IFS= read -r -d '' D; do
	folder "$D" 1
done < <(find "$SYNC_DIR" -mindepth 1 -type d -print0)

# copy all files
while IFS= read -r -d '' PDF; do
	fileinfo "$PDF"
	F="$PREFIX${PDF#"$SYNC_DIR/"}"
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
	cat > "$CACHE_DIR/$UUID.content" <<EOF
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

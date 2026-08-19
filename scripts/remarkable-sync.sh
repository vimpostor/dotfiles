#!/usr/bin/env bash

ARGS="hp:s:"
HELPMSG='This script copies a directory structure containing PDF files to a Remarkable and automatically imports it into the library.

Usage:
remarkable-sync.sh -s HOST -p Sheets /path/to/sync

-h: Show help
-p PREFIX: Directory to use for target install
-s HOST: SSH host name

In case the trailing argument is a regular file, only the given file will be synced into the target directory given by PREFIX.
If no trailing argument is provided, the current directory is synced.
'
CACHE_BASE="/tmp/.remarkable"
CACHE_DIR="$CACHE_BASE/xochitl"
CROP="$CACHE_BASE/crop"
PREFIX=""
PREFIX_DIRS=()
SSH_HOST=""

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

# compute optimal viewport using mupdf
g++ -DNDEBUG -std=c++23 -O3 -lmupdfcpp -o "$CROP" -x c++ - <<'EOF'
#include <print>
#include <mupdf/classes2.h>

constexpr const double customZoomPageFactor = 3.153;
constexpr const double customZoomScale = 0.813669990687162;

int scale(int n, int old) {
	return std::max(old, static_cast<int>(std::lround(n * customZoomPageFactor)));
}

bool blank(const unsigned char* p) {
	constexpr const int threshold = 3 * 0xFF - 0x40;
	return static_cast<int>(p[0]) + p[1] + p[2] > threshold;
}

double box(mupdf::FzPixmap& p, const int dir) {
	const bool mask = dir % 2;
	const int ydir = 1 - 2 * ((dir + (dir > 1)) % 2);
	const int xdir = 1 - 2 * (dir > 1);
	int y = (ydir < 0) * (p.h() - 1);
	int x = (xdir < 0) * (p.w() - 1);
	int r = 0;
	while (y >= 0 && y < p.h() && x >= 0 && x < p.w() && blank(&p.samples()[y * p.stride()] + x * p.n())) {
		y = (y + ydir * !mask + p.h()) % p.h();
		x = (x + xdir * mask + p.w()) % p.w();
		y = y + ydir * mask * !x;
		x = x + xdir * !mask * !y;
		r += mask * !x + !mask * !y;
	}
	return static_cast<double>(r) / (mask ? p.h() : p.w());
}

void cb(void*, const char*) {
}

int main(int argc, char *argv[])
{
	if (argc < 2) {
		return 1;
	}
	mupdf::fz_set_warning_callback(&cb, nullptr);
	mupdf::fz_set_error_callback(&cb, nullptr);
	mupdf::FzMatrix ctm;
	mupdf::FzDocument f = mupdf::fz_open_document(argv[1]);
	double b[4] {1, 1, 1, 1};
	int height = 0, width = 0;
	const int n = f.fz_count_pages();
	for (int i = 0; i < n; ++i) {
		auto pix = f.fz_new_pixmap_from_page_number(i, ctm, mupdf::fz_device_rgb(), 0);
		height = scale(pix.h(), height);
		width = scale(pix.w(), width);
		for (int j = 0; j < 4; ++j) {
			b[j] = std::min(b[j], box(pix, j));
		}
	}
	const double ycenter = (1 + b[3] - b[1]) / 2 * height;
	const double xcenter = (b[0] - b[2]) / 2 * width;
	const double diff = std::min(b[0] + b[2], b[1] + b[3]);
	const double zoom = customZoomScale / (1 - diff);
	std::println(R"({{"coverPageNumber": -1,"documentMetadata": {{}},"customZoomCenterX": {},"customZoomCenterY": {},"customZoomOrientation": "portrait","customZoomPageHeight": {},"customZoomPageWidth": {},"customZoomScale": {},"dummyDocument": false,"extraMetadata": {{}},"fileType": "pdf","fontName": "","lineHeight": -1,"pageCount": 0,"textScale": 1,"viewBackgroundFilter": "fullpage","zoomMode": "customFit"}})", xcenter, ycenter, height, width, zoom);
	return 0;
}
EOF

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

SOURCE_PREFIX="$SYNC_DIR"
if [ -f "$SOURCE_PREFIX" ]; then
	# not a directory
	SOURCE_PREFIX="$(dirname "$SOURCE_PREFIX")"
fi

# copy all files
while IFS= read -r -d '' PDF; do
	fileinfo "$PDF"
	F="$PREFIX${PDF#"$SOURCE_PREFIX/"}"
	uuid "$(dirname "$F")"
	PARENT="$UUID"
	uuid "$F"
	printf '\r' && tput el && printf '%s' "$F"
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
	"$CROP" "$PDF" > "$CACHE_DIR/$UUID.content"
	cp "$PDF" "$CACHE_DIR/$UUID.pdf"
	mkdir -p "$CACHE_DIR/$UUID"
	mkdir -p "$CACHE_DIR/$UUID.thumbnails"
	echo "Blank" > "$CACHE_DIR/$UUID.pagedata"
done < <(find "$SYNC_DIR" -type f -name '*.pdf' -print0)

echo ''
if [ -n "$SSH_HOST" ]; then
	scp -r "$CACHE_DIR" "root@$SSH_HOST:$TARGET_DIR"
	ssh "root@$SSH_HOST" 'systemctl restart xochitl'
fi

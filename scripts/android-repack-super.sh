#!/usr/bin/env bash
#
# Usage: android-repack-super.sh -s super.img -g gsi.zip -o out/super.img

ARGS="hs:g:o:fy"
HELPMSG='This script unpacks a stock firmware super image, replaces its contained system image with the system image of a provided Android GSI and repacks it into a new super.img.

The source super file can be either lz4 compressed (super.img.lz4), an Android sparse image (super.img) or a raw super file (super.raw).

The source GSI file can be either zip compressed (gsi.zip) or an already uncompressed single file (system.img).

Usage:
android-repack-super.sh -s super.img -g gsi.zip -o out/super.img

-h: Show help
-s FILE: The super.img file of the stock firmware
-g FILE: The GSI file (should contain a system.img when unpacked)
-o FILE: The new output super.img file
-f: Automatically flash after creating the super.img
-y: Do not ask for confirmations
'
SUPER_SOURCE="super.img"
GSI_SOURCE="gsi.zip"
SUPER_OUTPUT="out/super.img"
AUTO_FLASH=false
CONFIRM=true
WORK_DIR="$HOME/.cache/.super"
SUPER_COPY="$WORK_DIR/super.img"
WORK_TEMP="$WORK_DIR/temp"
SUPER_DIR="$WORK_DIR/super"
GSI_DIR="$WORK_DIR/gsi"
STOCK_SYSTEM_IMG="$SUPER_DIR/system.img"
GSI_SYSTEM_IMG="$GSI_DIR/system.img"

WHITE='\e[0m'
RED='\e[01;31m'
GREEN='\e[01;32m'
# Exit on error
set -e
error() {
	echo -e "${RED}Fatal: $*$WHITE" 1>&2
	exit 1
}

lpget() {
	LPGET="$(lpdump "$SUPER_COPY" -j | jq -r '.'"$1"'[] | select(.name == "'"$2"'") | .'"$3")"
}

commandcheck() {
	for PROG in "$@"; do
		if ! command -v "$PROG" 1>/dev/null; then
			error "Dependency $PROG is not installed"
		fi
	done
}

# First get options passed from CLI

while getopts $ARGS OPT; do
	case $OPT in
	h)
		printf "%s" "$HELPMSG"
		exit 0
		;;
	s)
		SUPER_SOURCE="$OPTARG"
		;;
	g)
		GSI_SOURCE="$OPTARG"
		;;
	o)
		SUPER_OUTPUT="$OPTARG"
		;;
	f)
		AUTO_FLASH=true
		;;
	y)
		CONFIRM=false
		;;
	:)
		error "Error: -$OPT requires an argument"
		;;
	?)
		error "Error: Unknown option -$OPT"
		;;
	esac
done

if ! [ -f "$SUPER_SOURCE" ]; then
	error "$SUPER_SOURCE is not a file"
elif ! [ -f "$GSI_SOURCE" ]; then
	error "$GSI_SOURCE is not a file"
fi

# Check that dependencies are installed
commandcheck unzip lz4 simg2img lpdump lpunpack lpmake jq
if "$AUTO_FLASH"; then
	commandcheck heimdall
fi

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$SUPER_DIR"

# We want to keep referencing the same file later, while also not overwriting the source file
ln -s "$SUPER_SOURCE" "$SUPER_COPY"

# Convert the super.img to the correct format
if file -Lb "$SUPER_COPY" | grep -iq 'lz4 compressed data'; then
	# super.img.lz4 -> super.img
	echo -e "${GREEN}Extracting the lz4 compressed super.img$WHITE"
	lz4 -d "$SUPER_COPY" "$WORK_TEMP"
	mv "$WORK_TEMP" "$SUPER_COPY"
fi
if file -Lb "$SUPER_COPY" | grep -iq 'android sparse image'; then
	# super.img -> super.raw
	echo -e "${GREEN}Extracting the stock sparse super.img file to a raw super file$WHITE"
	simg2img "$SUPER_COPY" "$WORK_TEMP"
	mv "$WORK_TEMP" "$SUPER_COPY"
fi

echo -e "${GREEN}Unpacking the raw super file to a super directory$WHITE"
lpunpack "$SUPER_COPY" "$SUPER_DIR"

test -f "$STOCK_SYSTEM_IMG" || error "Stock firmware does not contain a system.img file."

if file -b "$GSI_SOURCE" | grep -iq 'zip archive'; then
	# zip archive containing the system.img
	echo -e "${GREEN}Decompressing the GSI archive$WHITE"
	unzip "$GSI_SOURCE" -d "$GSI_DIR"
else
	# GSI source already is system.img
	mkdir -p "$GSI_DIR"
	cp "$GSI_SOURCE" "$GSI_SYSTEM_IMG"
fi
file -b "$GSI_SYSTEM_IMG" | grep -iq 'ext[2-4] filesystem data' || error "GSI archive does not contain a system.img file."

echo -e "${GREEN}Replacing stock system.img with GSI system.img$WHITE"
mv "$GSI_SYSTEM_IMG" "$STOCK_SYSTEM_IMG"

echo -e "${GREEN}Preparing metadata for repacking$WHITE"
declare -A PARTS
# Find out size of all partitions
for PART in "$SUPER_DIR/"*.img; do
	PARTS["$(basename "$PART")"]="$(stat --format="%s" "$PART")"
done
lpget block_devices super size
BLOCK_DEVICE_TABLE_SIZE="$LPGET"

# Verify that only one groupname is used
lpget partitions system group_name
GROUP_NAME="$LPGET"
PARTITION_ARGUMENTS=''
for PART in "${!PARTS[@]}"; do
	PART_NAME="${PART%.img}"
	lpget partitions "$PART_NAME" group_name
	if [ "$LPGET" != "$GROUP_NAME" ]; then
		echo -e "${RED}Ignoring $PART partition, because its group_name $LPGET does not match the system partition group_name $GROUP_NAME.$WHITE"
		unset 'PARTS["$PART"]'
	else
		# Convert into arguments for the lpmake command later
		PARTITION_ARGUMENTS="$PARTITION_ARGUMENTS --partition $PART_NAME:readonly:${PARTS["$PART"]}:$GROUP_NAME --image $PART_NAME=$SUPER_DIR/$PART"
	fi
done

# Get groups maximum size
lpget groups "$GROUP_NAME" maximum_size
GROUPS_MAX_SIZE="$LPGET"
METADATA_MAX_SIZE=65536

echo -e "${GREEN}Repacking super.img$WHITE with ${GREEN}${!PARTS[*]}$WHITE"
mkdir -p "$(dirname "$SUPER_OUTPUT")"
# shellcheck disable=SC2086
lpmake --metadata-size "$METADATA_MAX_SIZE" --super-name super --metadata-slots 2 --device super:"$BLOCK_DEVICE_TABLE_SIZE" --group "$GROUP_NAME:$GROUPS_MAX_SIZE" $PARTITION_ARGUMENTS --sparse --output "$SUPER_OUTPUT"
echo -e "${GREEN}Successfully created output super image at $SUPER_OUTPUT$WHITE"

# Clean up
rm -r "$WORK_DIR"

echo 'After flashing, make sure to first enter the recovery and reset to factory defaults before booting the image'
if "$AUTO_FLASH"; then
	echo -e "${GREEN}Flashing the super image onto the device$WHITE"
	if "$CONFIRM"; then
		echo -e "${GREEN}Press any key to start...$WHITE"
		read -rs
	fi
	heimdall flash --SUPER "$SUPER_OUTPUT" || true
else
	echo "Flash this by using: heimdall flash --SUPER $SUPER_OUTPUT"
fi

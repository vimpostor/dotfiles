#!/usr/bin/env bash
#
# Usage: android-repack-super.sh -s super.img -g gsi.zip -o out/super.img

ARGS="hs:g:o:"
HELPMSG='This script unpacks a stock firmware super image, replaces its contained system image with the system image of a provided Android GSI and repacks it into a new super.img, that can usually be flashed on Samsung devices with "heimdall flash --SUPER super.img".

Usage:
android-repack-super.sh -s super.img -g gsi.zip -o out/super.img

-h: Show help
-s FILE: The super.img file of the stock firmware
-g FILE: The GSI file (should contain a system.img when unpacked)
-o FILE: The new output super.img file
'
SUPER_SOURCE="super.img"
GSI_SOURCE="gsi.zip"
SUPER_OUTPUT="out/super.img"
WORK_DIR="$HOME/.cache/.super"
SUPER_RAW="$WORK_DIR/super.raw"
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
	LPGET="$(lpdump "$SUPER_RAW" -j | jq -r '.'"$1"'[] | select(.name == "'"$2"'") | .'"$3")"
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

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$SUPER_DIR"

echo 'Extracting the stock sparse super.img file to a raw super.raw file'
simg2img "$SUPER_SOURCE" "$SUPER_RAW"

echo 'Unpacking the super.raw file to a super directory'
lpunpack "$SUPER_RAW" "$SUPER_DIR"

test -f "$STOCK_SYSTEM_IMG" || error "Stock firmware does not contain a system.img file."

echo 'Unpacking the GSI ROM'
unzip "$GSI_SOURCE" -d "$GSI_DIR"
test -f "$GSI_SYSTEM_IMG" || error "GSI archive does not contain a system.img file."

echo 'Replacing stock system.img with GSI system.img'
mv "$GSI_SYSTEM_IMG" "$STOCK_SYSTEM_IMG"

echo 'Preparing metadata for repacking'
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
		echo "Ignoring $PART partition, because its group_name $LPGET does not match the system partition group_name $GROUP_NAME."
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

echo "Repacking super.img with ${!PARTS[*]}"
mkdir -p "$(dirname "$SUPER_OUTPUT")"
# shellcheck disable=SC2086
lpmake --metadata-size "$METADATA_MAX_SIZE" --super-name super --metadata-slots 2 --device super:"$BLOCK_DEVICE_TABLE_SIZE" --group "$GROUP_NAME:$GROUPS_MAX_SIZE" $PARTITION_ARGUMENTS --sparse --output "$SUPER_OUTPUT"

echo -e "${GREEN}Successfully created $SUPER_OUTPUT$WHITE"

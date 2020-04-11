#!/usr/bin/env bash

TEMP_FILE="/tmp/record_tmp.mkv"
OUTPUT_FILE="/tmp/out.webm"
RECORD_AUDIO="false"
VIDEO_BITRATE="1M"
FRAME_RATE="25"
SHOW_RECORDING_NOTIFICATION=true
ARGS="ab:d:ho:q"
HELPMSG="This program records the screen with minimal performance impact and transcodes it into a lossy format afterwards.

Usage:
-a: Enable Audio.
-b BITRATE: The video bitrate. Default: $VIDEO_BITRATE
-d SECONDS: Wait for the specified amount of time before recording.
-h: Show this help message.
-o FILE: Output the final result to FILE. Default: $OUTPUT_FILE
-q: Quiet run, do not show a GUI notification, when starting.
"

set -e

# prints an error and exits
error() {
	echo -e "$RED$*$WHITE" 1>&2
	exit 1
}
# sends a notification
function notify {
	notify-send -i simplescreenrecorder "$*"
}

# CLI args
while getopts $ARGS OPT; do
	case $OPT in
	a)
		RECORD_AUDIO=true
		;;
	b)
		VIDEO_BITRATE="$OPTARG"
		;;
	d)
		sleep "$OPTARG"
		;;
	h)
		printf "%s" "$HELPMSG"
		exit 0
		;;
	o)
		OUTPUT_FILE="$OPTARG"
		;;
	q)
		SHOW_RECORDING_NOTIFICATION=false
		;;
	:)
		error "Error: -$OPT requires an argument"
		;;
	?)
		error "Error: Unknown option -$OPT"
		;;
	esac
done

if "$SHOW_RECORDING_NOTIFICATION"; then
	notify "Recording..."
fi
RECORD_ARGS="-framerate $FRAME_RATE -f x11grab -s 1920x1080 -i :0.0+0,0 -r $FRAME_RATE"
if [ "$RECORD_AUDIO" = true ]; then
	RECORD_ARGS="$RECORD_ARGS -f pulse -ac 2 -i default"
fi
ffmpeg -y $RECORD_ARGS "$TEMP_FILE"
notify-send -i simplescreenrecorder -h string:x-kde-urls:"file://$TEMP_FILE" "Encoding..."
ffmpeg -y -i "$TEMP_FILE" -c:v libaom-av1 -strict experimental -b:v "$VIDEO_BITRATE" -pass 1 -an -f matroska /dev/null && \
	ffmpeg -i "$TEMP_FILE" -c:v libaom-av1 -strict experimental -b:v "$VIDEO_BITRATE" -pass 2 -c:a libopus "$OUTPUT_FILE"
notify-send -i simplescreenrecorder -h string:x-kde-urls:"file://$OUTPUT_FILE" "Finished encoding!"

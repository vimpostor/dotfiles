#!/usr/bin/env bash

FILEPATH="/tmp/.poll$FILESUFFIX"
DIFFPATH="$FILEPATH.diff"
GREPPATH="$FILEPATH.grep"
NEWFILEPATH="$FILEPATH.new"
INTERVAL=60
USERAGENT='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.128 Safari/537.36'
CALLBACK='notify-send'
GREP=0
GREPSTRING=''
CHECK=0
ARGS="A:c:g:hn:"
HELPMSG="This script can poll websites for changes and notifies you.

Usage:
poll.sh [OPTIONS] URL

Options:
-A USERAGENT: Useragent to use (Default: $USERAGENT).
-c CALLBACK: Notification method, can be one of {notify-send, echo} (Default: $CALLBACK).
-g GREP: Grep the website for a string before diffing.
-h: Show this help message.
-n SECONDS: Poll rate in seconds (Default: $INTERVAL).

Example:
poll.sh -n 5 'https://example.com'
"

# CLI args
while getopts $ARGS OPT; do
	case $OPT in
	A)
		USERAGENT="$OPTARG"
		;;
	c)
		CALLBACK="$OPTARG"
		;;
	g)
		GREP=1
		GREPSTRING="$OPTARG"
		;;
	h)
		printf "%s" "$HELPMSG"
		exit 0
		;;
	n)
		INTERVAL="$OPTARG"
		;;
	:)
		echo "Error: -$OPT requires an argument"
		exit 1
		;;
	?)
		echo "Error: Unknown option -$OPT"
		exit 1
		;;
	esac
done
shift $((OPTIND -1))

URL="$*"


# poll
while true; do
	curl -s -A "$USERAGENT" "$URL" -o "$NEWFILEPATH"
	if [[ "$GREP" -eq 1 ]]; then
		grep -Ei "$GREPSTRING" "$NEWFILEPATH" > "$GREPPATH"
		mv "$GREPPATH" "$NEWFILEPATH"
	fi
	if [[ "$CHECK" -eq 1 ]]; then
		if ! diff -q "$FILEPATH" "$NEWFILEPATH" &> /dev/null; then
			diff "$FILEPATH" "$NEWFILEPATH" > "$DIFFPATH"
			case "$CALLBACK" in
			notify-send)
				notify-send -i web-browser -u critical -h string:x-kde-urls:"file://$DIFFPATH" 'Website Activity' "Click <a href=\"$URL\">here</a> to visit the page now!"
				;;
			echo)
				echo "Activity on website $URL"
				;;
			*)
				echo "Unknown notification method"
				;;
			esac
		fi
	fi
	CHECK=1
	mv "$NEWFILEPATH" "$FILEPATH"
	sleep "$INTERVAL"
done

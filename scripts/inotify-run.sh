#!/usr/bin/env bash
# Runs the given command everytime a file changes in the current directory

KILL=false
PID=""
FIRST=true

ARGS="hk"
HELPMSG="This program runs the given command every time that a file in the current directory changes.

Usage:
-h: Show this help message.
-k: Kill the command instead of waiting for it to exit, once the file changes
"

while getopts $ARGS OPT; do
	case $OPT in
	h)
		printf "%s" "$HELPMSG"
		exit 0
		;;
	k)
		KILL=true
		;;
	:)
		error "Error: -$OPT requires an argument"
		;;
	?)
		error "Error: Unknown option -$OPT"
		;;
	esac
done
shift $((OPTIND -1))

while "$FIRST" || inotifywait -qq -r -e modify .; do
	FIRST=false
	# sleep for a short while so that all files are saved
	sleep 0.2
	if "$KILL"; then
		if [ -n "$PID" ]; then
			kill "$PID"
		fi
		"$@" &
		PID=$!
	else
		"$@"
		echo "Exited with code $?"
	fi

	# Sleep for a short while to bundle all events in one roundtrip.
	# We sleep in two separate steps in order to improve latency,
	# as we don't want to burden the initial call with such a huge delay.
	sleep 0.5
done

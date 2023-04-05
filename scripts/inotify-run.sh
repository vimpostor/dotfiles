#!/usr/bin/env bash
# Runs the given command everytime a file changes in the current directory

while inotifywait -qq -r -e modify .; do
	# sleep for a short while to bundle all events in one roundtrip
	sleep 0.2

	"$@"
	echo "Exited with code $?"
done

#!/usr/bin/env bash
# Runs the given command everytime a file changes in the current directory

while inotifywait -qq -r -e modify .; do
	# sleep for a short while so that all files are saved
	sleep 0.2
	"$@"
	echo "Exited with code $?"

	# Sleep for a short while to bundle all events in one roundtrip.
	# We sleep in two separate steps in order to improve latency,
	# as we don't want to burden the initial call with such a huge delay.
	sleep 0.5
done

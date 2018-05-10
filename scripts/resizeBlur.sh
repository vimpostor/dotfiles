#!/usr/bin/env bash

bspc subscribe pointer_action | while read -a msg; do
	EVENT=${msg[5]}
	WID=${msg[3]}
	if [ "$EVENT" = "begin" ]; then
		OPACITY=0xaaaaaaaa
	else
		OPACITY=0xffffffff
	fi
	# set opacity of the current window
	xprop -id "$WID" -f _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY $OPACITY
done

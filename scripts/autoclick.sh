#!/usr/bin/env bash
# usage: (optionally timer interval can be given as parameter)
# autoclick.sh 0.1

N="${*-0.05}"
# find out keyboard xinput id
ID="$(xinput list| grep -A10 'core keyboard'| tail +2| grep -i 'keyboard.*id'| grep -v 'XTEST'| head -1 | grep -oE 'id=[0-9]+'| sed 's/id=//')"
KEYCODE=64

sleep 3
while sleep "$N"; do
	# Disable if Alt is currently pressed
	if xinput query-state "$ID" | grep "\[$KEYCODE\]" | grep 'up' >/dev/null; then
		xdotool click 1
	fi
done

#!/usr/bin/env bash

# This option configures how high the window will be. 1 means fullscreen and 0 means no height.
REL_HEIGHT='0.2'

YOFFSET=10
MONITOR_HEIGHT=$(xwininfo -root| grep -Eo 'Height.*'| cut -d ' ' -f2)
WIDTH=$(xwininfo -root| grep -Eo 'Width.*'| cut -d ' ' -f2)
ABS_HEIGHT=$(echo "$REL_HEIGHT * $MONITOR_HEIGHT / 1" | bc)
YPOS=$((MONITOR_HEIGHT - ABS_HEIGHT + YOFFSET))

# if there already is an instance running, kill it
if xdotool search --classname "transparentCava"; then
	xdotool search --classname "transparentCava" windowkill
	exit 0
fi
bspc rule -a transparentCava -o state=floating manage=off
alacritty --config-file ~/.config/alacritty/transparent.yml --title "transparentCava" -e "cava" &
WID=""
# wait for the window to be spawned
while [ -z "$WID" ]; do
	sleep 0.1
	WID=$(xdotool search --classname "transparentCava"| tail -1)
done
xdotool windowmove "$WID" 0 "$YPOS"
xdotool windowsize "$WID" "$WIDTH" "$ABS_HEIGHT"

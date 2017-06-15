#!/usr/bin/env bash

if xdotool search --classname "transparentCava"; then
	xdotool search --classname "transparentCava" windowkill
	exit 0
fi
bspc rule -a transparentCava -o state=floating manage=off
termite -c ~/.config/termite/transparent-config -e "cava" --geometry=1920x200 --class=transparentCava --name=transparentCava&
sleep 0.1
WID=$(xdotool search --classname "transparentCava"| tail -1)
xdotool windowmove $WID 0 898

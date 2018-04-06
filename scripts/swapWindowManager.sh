#/usr/bin/env bash

if pidof bspwm ; then
	pkill compton && pkill sxhkd && pkill bspwm && kwin_x11 --replace &>/dev/null &disown
else
	pkill kwin_x11 && bspwm &>/dev/null &disown
fi

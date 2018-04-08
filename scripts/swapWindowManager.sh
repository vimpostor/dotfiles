#/usr/bin/env bash

if pidof bspwm ; then
	pkill compton && pkill sxhkd && pkill bspwm && kwin_x11 --replace &>/dev/null &disown
else
	pkill kwin_x11 && sleep 1 && bspwm &disown && sleep 3 && bspc wm -o && xdotool search --classname krunner windowclose
fi

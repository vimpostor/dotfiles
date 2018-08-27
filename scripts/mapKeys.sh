#!/usr/bin/env bash

if command -v xcape &>/dev/null; then
	# if xcape exists bind caps lock to both escape and ctrl
	setxkbmap de -option caps:ctrl_modifier
	xcape -e 'Caps_Lock=Escape'
else
	# else fall back to just binding caps lock to escape
	setxkbmap de -option caps:escape
fi

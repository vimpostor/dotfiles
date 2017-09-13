#!/usr/bin/env bash

# Toggles the left padding

PANELWIDTH=53
NEWPADDING=0

MONITORS=$(bspc query -M)
PRIMMONITOR=$(echo "$MONITORS"| head -1)

if (( $(bspc config -m "$PRIMMONITOR" left_padding) == $NEWPADDING )); then
	NEWPADDING=$PANELWIDTH
fi

bspc config -m "$PRIMMONITOR" left_padding $NEWPADDING

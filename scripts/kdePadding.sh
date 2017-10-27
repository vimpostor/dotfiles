#!/usr/bin/env bash

# Toggles the left padding

PANELWIDTH=53
NEWPADDING=0

MON="$(bspc query -M -m)"

if (( $(bspc config -m "$MON" left_padding) == $NEWPADDING )); then
	NEWPADDING=$PANELWIDTH
fi

bspc config -m "$MON" left_padding $NEWPADDING

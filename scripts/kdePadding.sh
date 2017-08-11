#!/usr/bin/env bash

# Toggles the left padding

PANELWIDTH=58
NEWPADDING=0

if (( $(bspc config left_padding) == $NEWPADDING )); then
	NEWPADDING=$PANELWIDTH
fi

bspc config left_padding $NEWPADDING

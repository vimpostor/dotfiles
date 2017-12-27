export XDG_CONFIG_HOME="$HOME/.config"
export ALSA_CARD=PCH
export LESS="-Ri"
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
	export KDEWM=bspwm
fi
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && [ -z "$KDEWM" ]; then
	exec startx
fi


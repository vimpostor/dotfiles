export XDG_CONFIG_HOME="$HOME/.config"
export ALSA_CARD=PCH
export KDEWM=bspwm
export LESS="-Ri"
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && [ -z "$KDEWM" ]; then
	exec startx
fi


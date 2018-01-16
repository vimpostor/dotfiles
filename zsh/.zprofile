export XDG_CONFIG_HOME="$HOME/.config"
export ALSA_CARD=PCH
export LESS="-Ri"
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
	export KDEWM=bspwm
fi

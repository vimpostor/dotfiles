export XDG_CONFIG_HOME="$HOME/.config"
export QT_QPA_PLATFORMTHEME="qt5ct"
export ALSA_CARD=PCH
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
	exec startx
fi


#!/usr/bin/env bash
# Pipe an out-of-date notification email into this script and it will automatically find out which package to update and build a new version in a background tmux window

set -e

# Decodes MIME RFC 2047 to UTF8
function decode() {
	DECODER="use utf8; print decode(\"MIME-Header\", \"${*//\"/}\")"
	DECODED="$(echo "" | perl -CS -MEncode -ne "$DECODER" || echo 'Parse Error')"
}

# Example subject line:
# Subject: AUR Out-of-date Notification for veloren-nightly-bin
SUBJECT="$(grep -A1 -m1 '^Subject:' | grep -E '^Subject: |^\s.' | sed 's/^Subject://' |  sed 's/^\s*\|\s*$//g' | tr '\n' ' ' | sed 's/ $//')"
decode "$SUBJECT"
PKGNAME="${DECODED##*Notification for }"
if [ -z "$PKGNAME" ]; then
	exit 1
fi

# spawn background tmux window
WINDOW_ID="$(tmux new-window -d -c ~/Documents/Miscellaneous/AUR/"$PKGNAME" -P -F '#{window_index}' "$HOME/Documents/scripts/update-pkgbuild.sh; ID=\$(gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.Notify 'makepkg' 0 'Finished' 'Package build finished' 'Job for $PKGNAME finished.' '[]' '{\"desktop-entry\": <\"org.kde.konsole\">}' 5000 | grep -Eo 'uint32\s[[:digit:]]+'| cut -d' ' -f2); zsh; gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.CloseNotification \$ID")"
tmux rename-window -t "$WINDOW_ID" "$PKGNAME"

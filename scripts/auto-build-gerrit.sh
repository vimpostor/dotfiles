#!/usr/bin/env bash
# Pipe a Gerrit "newchange" patchset notification email into this script and it will automatically checkout and build the new patch in a background tmux window

set -e

CHANGE_NUMBER="$(grep -m1 '^X-Gerrit-Change-Number: [0-9]\+$' | grep -o '[0-9]\+')"
WINDOW_ID="$(tmux new-window -d -P -F '#{window_index}' "zsh -ic 'gcpr $CHANGE_NUMBER'; cmake --build build; ID=\$(gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.Notify 'Gerrit Patchset' 0 'format-text-code' 'Build finished' 'Job for change number $CHANGE_NUMBER finished.' '[]' '{\"desktop-entry\": <\"org.wezfurlong.wezterm\">}' 5000 | grep -Eo 'uint32\s[[:digit:]]+'| cut -d' ' -f2); zsh; gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.CloseNotification \$ID")"
# TODO: Show the Gerrit project name ("X-Gerrit-Project") as the tab name
tmux rename-window -t "$WINDOW_ID" "gerrit"

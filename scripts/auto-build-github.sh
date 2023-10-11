#!/usr/bin/env bash
# Pipe a Github PR notification email into this script and it will automatically checkout and build the new patch in a background tmux window

set -e

# Decodes MIME RFC 2047 to UTF8
function decode() {
	ESCAPED="${*//\"/}"
	ESCAPED="${ESCAPED//\@/\\\@}"
	DECODER="use utf8; print decode(\"MIME-Header\", \"$ESCAPED\")"
	DECODED="$(echo "" | perl -CS -MEncode -ne "$DECODER" || echo 'Parse Error')"
}

# Example subject line:
# Subject: [vimpostor/vim-tpipeline] Use exists('##ModeChanged') to check for ModeChanged (PR #18)
SUBJECT="$(grep -A1 -m1 '^Subject:' | grep -E '^Subject: |^\s.' | sed 's/^Subject://' |  sed 's/^\s*\|\s*$//g' | tr '\n' ' ' | sed 's/ $//')"
decode "$SUBJECT"
PR_ID="${DECODED##*PR #}"
PR_ID="${PR_ID%)}"
REPO="${DECODED%%] *}"
REPO="${REPO##*/}"
WINDOW_ID="$(tmux new-window -d -P -F '#{window_index}' "zsh -ic 'gcpr $PR_ID'; make; ID=\$(gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.Notify 'Github PR' 0 'github-desktop' 'Build finished' 'Job for $REPO PR #$PR_ID finished.' '[]' '{\"desktop-entry\": <\"org.wezfurlong.wezterm\">}' 5000 | grep -Eo 'uint32\s[[:digit:]]+'| cut -d' ' -f2); zsh; gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.CloseNotification \$ID")"
tmux rename-window -t "$WINDOW_ID" "$REPO #$PR_ID"

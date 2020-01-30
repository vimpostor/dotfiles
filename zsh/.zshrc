if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# powerlevel10k status prompt
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ssh context dir dir_writable vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time root_indicator background_jobs)
POWERLEVEL9K_SHOW_RULER=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true

# plugins
# Check if zgen is installed
if [[ ! -d ~/.zgen ]]; then
	echo 'Installing zgen...'
	git clone -q https://github.com/tarjoilija/zgen.git ~/.zgen
fi
source ~/.zgen/zgen.zsh
if ! zgen saved; then
	echo 'Installing plugins...'

	zgen oh-my-zsh
	zgen oh-my-zsh plugins/git
	zgen oh-my-zsh plugins/colored-man-pages
	zgen oh-my-zsh plugins/sudo

	zgen load zsh-users/zsh-completions
	zgen load zsh-users/zsh-autosuggestions
	zgen load zdharma/fast-syntax-highlighting

	zgen load romkatv/powerlevel10k powerlevel10k
	zgen save
fi

# aliases
alias vim='vim --servername vim'
alias lazyCommit='git commit -m "$(curl -s whatthecommit.com/index.txt)"'
alias vi=vim
alias diff='diff --color=auto'
alias clipboard='xclip -selection c'
alias ip='ip --color'
alias ls='ls --color=auto'

# functions
# use xdg-open to open all passed files
function o() {
	for i in "$@"; do
		xdg-open "$i"
	done
}

# play youtube audio by URL
function ytaudio() {
	mpv --no-resume-playback --no-video --ytdl-format=bestaudio --ytdl "$*"
}

# play youtube video by URL
function ytvideo() {
	mpv --no-resume-playback --fullscreen --ytdl-format='bestvideo[height<=1080]+bestaudio/best' --ytdl "$*"
}

# play youtube video by search
function ytsearch() {
	mpv --no-resume-playback --fullscreen --ytdl-format='bestvideo[height<=1080]+bestaudio/best' ytdl://ytsearch10:"$*"
}

# gource, but with sane defaults
function autogource() {
	git log --pretty='%at|%s' | sort -n > /tmp/gourceCaption.txt && gource -1920x1080 -r 25 -f -b 263238 --key --dir-colour cfd8dc -s 1 --highlight-dirs --caption-file /tmp/gourceCaption.txt --caption-duration 1 --caption-size 13
}

# man page for plebs
function cheat() {
	if ! curl -s "cheat.sh/${*//\ /+}"; then
		echo "Failed to get the cheatsheet" >&2
		return 1
	fi
}

# vote for AUR packages
function aurvote() {
	ssh aur@aur.archlinux.org vote "$*"
}

export KEYTIMEOUT=1
# complete autosuggestions with <c-space>
bindkey '^ ' autosuggest-accept

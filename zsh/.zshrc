if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# powerlevel10k status prompt
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ssh context dir vcs kubecontext newline prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time root_indicator background_jobs)
typeset -g POWERLEVEL9K_MODE=nerdfont-complete
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='·'
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=
typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%{%}'
typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='\uE0BD'
typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='\uE0BD'
typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0BC'
typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0BA'
typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0BC'
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='\uE0BA'
typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0BC'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=255
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=true
typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm'
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir
typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
typeset -g ZLE_RPROMPT_INDENT=0

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
	zgen oh-my-zsh plugins/fzf

	zgen load zsh-users/zsh-completions
	zgen load zsh-users/zsh-autosuggestions
	zgen load zdharma-continuum/fast-syntax-highlighting
	zgen load romkatv/powerlevel10k powerlevel10k
	zgen save
fi

# aliases
alias lazycommit='git commit -m "$(curl -s whatthecommit.com/index.txt)"'
alias diff='diff --color=auto'
alias clipboard='xclip -selection c'
alias ip='ip -c'
alias ls='ls --color=auto'
alias gce='git commit --amend --no-edit'

# functions
# use xdg-open to open all passed files
function o() {
	for i in "$@"; do
		xdg-open "$i"
	done
}

# man page for plebs
function cheat() {
	if ! curl -s "cheat.sh/${*//\ /+}"; then
		echo "Failed to get the cheatsheet" >&2
		return 1
	fi
}

# retreives a pkgbuild
function get-pkgbuild() {
	asp export "$*" || paru -G "$*" && cd "$*"
}

# vote for AUR package
function aurvote() {
	(($#)) && P="$*" || P="$(history| grep 'paru -S '| tail -1| sed 's/.*paru -S\s\+//')"
	ssh aur@aur.archlinux.org vote "$P" && echo "👍 $P 👍"
}

# modifies grep to highlight instead of filter
function highlight() {
	grep --color=auto -e '^' "$@"
}

# creates a file from a template
# Usage: templ newscript.sh
function templ() {
	cp ~/Templates/.filetemplates/*."${*##*.}" "$*"
}

# generates an Ansible role using molecule
function gen-molecule() {
	molecule init role -d podman "$*" && cd "$*" && rm README.md .travis.yml meta/main.yml
}

# generate vim compatible cmake build
function gen-cmake-debug() {
	cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=1 "$@" && ln -sf build/compile_commands.json .
}

# deletes a git branch
unalias gbd
function gbd() {
	git branch -D "$*" && git push origin --delete "$*"
}

# rebase current branch on top of upstream remote changes
function greb() {
	UPSTREAM="$(git remote | grep upstream || git remote | grep origin)"
	DEFAULT_BRANCH="$UPSTREAM/$(git branch -rl \*/HEAD | head -1 | rev | cut -d/ -f1 | rev)"
	git fetch "$UPSTREAM" && git --no-pager log --reverse --pretty=tformat:%s "$(git merge-base HEAD "$DEFAULT_BRANCH")".."$DEFAULT_BRANCH" && git rebase "$DEFAULT_BRANCH"
}

# checkout a PR without polluting local repo, takes the PR ID as single argument
function gcpr() {
	git fetch -q origin pull/"$*"/head 2>/dev/null || git fetch -q upstream pull/"$*"/head && git checkout FETCH_HEAD
}

# create a signed git tag, usage: gta v1.2
function gta() {
	git tag -s -m "$(basename "$(git rev-parse --show-toplevel)") ${*#v}" "$*" && git --no-pager tag -n "$*"
}

# complete autosuggestions with <c-space>
bindkey '^ ' autosuggest-accept

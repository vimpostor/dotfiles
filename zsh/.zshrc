if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# powerlevel10k status prompt
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ssh nix_shell context dir vcs kubecontext newline prompt_char)
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
typeset -g POWERLEVEL9K_TERM_SHELL_INTEGRATION=true
typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
typeset -g ZLE_RPROMPT_INDENT=0

# plugins
if [[ ! -d ~/.zgenom ]]; then
	echo 'Installing zgenom...'
	git clone -q https://github.com/jandamm/zgenom.git ~/.zgenom
fi
source ~/.zgenom/zgenom.zsh
if ! zgenom saved; then
	echo 'Installing plugins...'

	zgenom oh-my-zsh
	zgenom oh-my-zsh plugins/git
	zgenom oh-my-zsh plugins/sudo
	zgenom oh-my-zsh plugins/fzf

	zgenom load zsh-users/zsh-completions
	zgenom load zsh-users/zsh-autosuggestions
	zgenom load zdharma-continuum/fast-syntax-highlighting
	zgenom load atuinsh/atuin
	zgenom load romkatv/powerlevel10k powerlevel10k
	zgenom save
	zgenom compile ~/.zshrc
fi

# aliases
alias lazycommit='git commit -m "$(curl -s whatthecommit.com/index.txt)"'
alias diff='diff --color=auto'
alias cb='xclip -selection c'
alias ip='ip -c'
alias ls='ls --color=auto'
alias gce='git commit --amend --no-edit'
alias gcea='gce -a'
alias gpf='git push --force-with-lease --force-if-includes'

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
	GIT_TERMINAL_PROMPT=0 git clone "https://gitlab.archlinux.org/archlinux/packaging/packages/$*.git" || paru -G "$*" && cd "$*"
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

# start mutt in the correct mode
function mutt() {
	if pgrep -xu "$USER" mutt >/dev/null; then
		echo 'Starting mutt in read-only mode 🔒' && sleep 0.2
		command mutt -R "$@"
	else
		command mutt "$@"
	fi
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
	BRANCH="$UPSTREAM/${$(git branch -rl \*/HEAD | head -1 | rev | cut -d/ -f1 | rev):-master}"
	git fetch "$UPSTREAM" && git --no-pager log --reverse --pretty=tformat:%s "$(git merge-base HEAD "$BRANCH")".."$BRANCH" && git rebase "$BRANCH"
}

# checkout a PR without polluting local repo, takes the PR ID as single argument
function gcpr() {
	git fetch -q origin pull/"$*"/head 2>/dev/null || git fetch -q upstream pull/"$*"/head 2>/dev/null || git fetch -q origin merge-requests/"$*"/head 2>/dev/null || git fetch -q upstream merge-requests/"$*"/head && git checkout FETCH_HEAD
}

# create a signed git tag, usage: gta v1.2
function gta() {
	git tag -se -m "$(basename "$(git rev-parse --show-toplevel)") ${*#v}" "$*" && git --no-pager tag -n "$*"
}

bindkey '^r' _atuin_search_widget
# complete autosuggestions with <c-space>
bindkey '^ ' autosuggest-accept

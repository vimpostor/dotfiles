# zplug
source ~/.zshplug

# aliases
source ~/.zshalias

# functions
source ~/.zshfunction

# complete autosuggestions with <c-space>
bindkey '^ ' autosuggest-accept
# history search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# general keybindings
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[Z' reverse-menu-complete
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# history
export HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history

# bullet train status prompt
BULLETTRAIN_PROMPT_ORDER=(status context dir git cmd_exec_time)
BULLETTRAIN_STATUS_EXIT_SHOW=true

# zplug
source ~/.zshplug

# aliases
source ~/.zshalias

# functions
source ~/.zshfunction

# complete autosuggestions with <c-space>
bindkey '^ ' autosuggest-accept

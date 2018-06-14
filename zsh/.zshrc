# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="gnzh"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git colored-man-pages sudo zsh-autosuggestions)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
	source $ZSH/oh-my-zsh.sh
fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
source ~/.zshalias

# autocompletion for command forecast
bindkey '^ ' autosuggest-accept

# use xdg-open to open all passed files
function o() {
	for i in "$@"; do
		xdg-open "$i"
	done
}

# play youtube audio by URL
function ytaudio() {
	mpv --no-resume-playback --no-video --ytdl-format=bestaudio --ytdl "$@"
}

# play youtube video by URL
function ytvideo() {
	mpv --no-resume-playback --fullscreen --ytdl-format='bestvideo[height<=1080]+bestaudio/best' --ytdl "$@"
}

function ytsearch() {
	mpv --no-resume-playback --fullscreen --ytdl-format='bestvideo[height<=1080]+bestaudio/best' ytdl://ytsearch10:"$@"
}

function record() {
	sleep 1 && rm $@; ffmpeg -f x11grab -s 1920x1080 -i :0.0+0,0 -r 20 -c:v libx264 -b:v 1000k $@
}

function autogource() {
	git log --pretty='%at|%s' | sort -n > /tmp/gourceCaption.txt && gource -1920x1080 -r 25 -f -b 263238 --key --dir-colour cfd8dc -s 1 --highlight-dirs --caption-file /tmp/gourceCaption.txt --caption-duration 1 --caption-size 13
}

if [ -f '/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' ]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

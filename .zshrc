HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
bindkey -e


### ALIASES ###

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c="clear"
alias start="dcmd run start"
alias s="dcmd run start"
alias t="dcmd run test"
alias home="cd ~"
alias dcu="docker compose up"
alias dcb="docker compose build"
alias dcub="docker compose up --build"
alias pf="platform"
alias dr="dotnet run"
alias dwr="dotnet watch run"
alias dwt="dotnet watch test"
alias dt="dotnet test"
alias dtf="dotnet test --filter"
alias portfind="sudo lsof -i -P | grep"
alias pidpath="ps xuwww -p"
alias portpid="sudo lsof -i -P | grep LISTEN | grep"
alias reload="source ~/.zshrc && source ~/.zprofile"
alias ztime="time zsh -i -c exit"


### SHELL CUSTOMIZATION ###

# antigen
if [[ ! -f ~/.antigen.zsh ]]; then
	curl -L https://raw.githubusercontent.com/zsh-users/antigen/master/bin/antigen.zsh > ~/.antigen.zsh
fi

source ~/.antigen.zsh

antigen bundle agkozak/zsh-z
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle MichaelAquilina/zsh-you-should-use
antigen bundle extract

PLUGINS="$HOME/.zsh/plugins"
antigen bundle $PLUGINS/android
antigen bundle $PLUGINS/dcmd
antigen bundle $PLUGINS/ef
antigen bundle $PLUGINS/utils

PLUGINS_FB="$HOME/.zsh/firebend/plugins"
antigen bundle $PLUGINS_FB/ct
antigen bundle $PLUGINS_FB/dp
antigen bundle $PLUGINS_FB/platform

antigen apply

# starship
if ! command -v starship &> /dev/null
then
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
fi

eval "$(starship init zsh)"


### INITS ###

# fnm
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd)"
fi

# pyenv
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

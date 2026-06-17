HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
bindkey -e


# aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
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
if [[ -o interactive ]] && command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias l='eza -1'
  alias la='eza -a'
  alias ll='eza -la --git --icons=auto'
  alias lt='eza --tree --level=2 --icons=auto'
else
  alias ls='ls -G'
  alias l='ls -1'
  alias la='ls -a'
  alias ll='ls -laG'
fi


# antigen
if [[ -f ~/.antigen.zsh ]]; then
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
fi

# starship
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# fnm
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd)"
fi

# pyenv
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

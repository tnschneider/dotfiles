HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt AUTO_CD
bindkey -e


# antigen
if [[ -f ~/.antigen.zsh ]]; then
    source ~/.antigen.zsh

    antigen bundle agkozak/zsh-z
    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle MichaelAquilina/zsh-you-should-use
    antigen bundle extract
    antigen bundle encode64

    PLUGINS="$HOME/.zsh/plugins"
    antigen bundle $PLUGINS/android
    antigen bundle $PLUGINS/dcmd
    antigen bundle $PLUGINS/ef
    antigen bundle $PLUGINS/todos
    antigen bundle $PLUGINS/utils

    PLUGINS_FB="$HOME/.zsh/firebend/plugins"
    antigen bundle $PLUGINS_FB/ct
    antigen bundle $PLUGINS_FB/dp
    antigen bundle $PLUGINS_FB/platform

    antigen apply
fi

# aliases
alias ...="cd ../.."
alias ....="cd ../../.."
alias c="clear"
alias g="git"
alias start="dcmd run start"
alias s="dcmd run start"
alias t="dcmd run test"
alias dcu="docker compose up"
alias dcb="docker compose build"
alias dcub="docker compose up --build"
alias pf="platform"
alias dr="dotnet run"
alias dwr="dotnet watch run"
alias dwt="dotnet watch test"
alias db="dotnet build"
alias dc="dotnet clean"
alias dt="dotnet test"
alias dtf="dotnet test --filter"
alias portfind="sudo lsof -i -P | grep"
alias pidpath="ps xuwww -p"
alias portpid="sudo lsof -i -P | grep LISTEN | grep"
alias reload="source ~/.zprofile && source ~/.zshrc"
alias ztime="time zsh -i -c exit"
alias path='echo $PATH | tr ":" "\n"'
alias which="which -a"
alias back="cd -"
alias up="cd .."
alias home="cd ~"
alias desktop="cd ~/Desktop"
alias downloads="cd ~/Downloads"
alias repos="cd ~/Repos"
alias todo="open https://app.todoist.com/app/project/$DEFAULT_TODOIST_PROJECT"
alias fzr="rg --files | fzf --preview 'bat --style=numbers --color=always {}' | xargs bat"
alias fzo="rg --files | fzf --preview 'bat --style=numbers --color=always {}' | xargs open"
alias fze="rg --files | fzf --preview 'bat --style=numbers --color=always {}' | xargs $EDITOR"
if command -v eza >/dev/null 2>&1; then
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

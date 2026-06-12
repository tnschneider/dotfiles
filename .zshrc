HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=50000
bindkey -e


### ENV VARS ###
export ASPNETCORE_ENVIRONMENT="Development"
export AZURE_FUNCTIONS_ENVIRONMENT="Development"
export DOTNET_WATCH_RESTART_ON_RUDE_EDIT=1
export REPO_HOME="$HOME/Repos"


### ALIASES ###
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c="clear"
alias dcu="docker compose up"
alias dcb="docker compose build"
alias dcub="docker compose up --build"
alias pf="platform"
alias dr="dotnet run"
alias pnpx="pnpm dlx"
alias python=python3
alias pip=pip3
alias portfind="sudo lsof -i -P | grep"
alias zshrc="source ~/.zshrc"
alias pidpath="ps xuwww -p"
alias portpid="sudo lsof -i -P | grep LISTEN | grep"
alias s="start"
alias home="cd ~"


### FUNCTIONS AND COMPLETIONS ###

fpath=(~/.zsh $fpath)

autoload -Uz funcinit compinit

funcinit ~/.zsh

# Firebend
fpath=(~/.zsh.fb $fpath)

funcinit ~/.zsh.fb

compinit -C

# Platform extensions
PLATFORM_HOME="$REPO_HOME"
PF_SH_EXT="$PLATFORM_HOME/ct-platform/platform-developers/platform-sh-extensions.sh"
test -f $PF_SH_EXT && source $PF_SH_EXT


### SHELL CUSTOMIZATION ###

# antigen
if [[ ! -f ~/.antigen.zsh ]]; then
	curl -L https://raw.githubusercontent.com/zsh-users/antigen/develop/bin/antigen.zsh > ~/.antigen.zsh
fi

source ~/.antigen.zsh

antigen bundle agkozak/zsh-z
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle MichaelAquilina/zsh-you-should-use
antigen bundle extract

antigen apply

# starship
if ! command -v starship &> /dev/null
then
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
fi

eval "$(starship init zsh)"


### APPLICATIONS ###

# yarn
export PATH=$PATH:~/.yarn/bin

# local bin
export PATH="$HOME/.local/bin:$PATH"

# pyenv
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# dotnet tools
export PATH="$PATH:$HOME/.dotnet/tools"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pnpm completion
if command -v pnpm >/dev/null 2>&1; then
	eval "$(pnpm completion zsh)"
fi

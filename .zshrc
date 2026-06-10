HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=50000
bindkey -e

fpath=(~/.zsh $fpath)

autoload -Uz compinit

compinit -C


################
### ENV VARS ###
################

export ASPNETCORE_ENVIRONMENT="Development"
export AZURE_FUNCTIONS_ENVIRONMENT="Development"
export DOTNET_WATCH_RESTART_ON_RUDE_EDIT=1
export REPO_HOME="$HOME/Repos"


###############
### ALIASES ###
###############

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


#################
### FUNCTIONS ###
#################

# Keep a command running in a loop
keepalive() {
	while true; do
		"$@"
		sleep 1
	done
}

# Wait for a key press before executing a command
anykey() {
	read -k1 -s REPLY\?"Press any key to execute \"$*\" "
	case "$REPLY" in 
		*) eval "$@"
		;; 
	esac
}

# Execute command in STARTCMD env variable
start() {
	printf "$STARTCMD\n"
	eval "$STARTCMD"
}

# Print the STARTCMD env variable
printstart() {
	echo $STARTCMD
}


#################
### SHORTCUTS ###
#################

# repos
repo() {
	cd "$REPO_HOME/$1"
}

_repo_completions() {
  compadd -- "$REPO_HOME"/*(/:t)
}

compdef _repo_completions repo


# dotnet ef shorthand: mg[a] = migrations [add], db[u] = database [update]
ef() {
	local cmd=$1; shift
	case $cmd in
		mg|migrations)  dotnet ef migrations "$@" ;;
		mga)            dotnet ef migrations add "$@" ;;
		db|database)    dotnet ef database "$@" ;;
		dbu)            dotnet ef database update "$@" ;;
		-h|--help|"")   echo "Usage: ef [mg|mga|db|dbu] [args]
  mg, migrations   dotnet ef migrations <args>
  mga <name>       dotnet ef migrations add <name>
  db, database     dotnet ef database <args>
  dbu [args]       dotnet ef database update [args]" ;;
		*)              dotnet ef "$cmd" "$@" ;;
	esac
}

_ef_completions() {
	compadd mg migrations mga db database dbu
}

compdef _ef_completions ef

############################
### ENVIRONMENT-SPECIFIC ###
############################

# Firebend
test -f ~/.zshrc.fb && source ~/.zshrc.fb


###########################
### SHELL CUSTOMIZATION ###
###########################

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


####################
### APPLICATIONS ###
####################
 
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

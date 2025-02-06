# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/tnsch/.zshrc'

fpath=(~/.zsh $fpath)

autoload -Uz compinit
compinit
# End of lines added by compinstall

autoload bashcompinit
bashcompinit

REPO_HOME="$HOME/Repos"

PF_SH_EXT="$REPO_HOME/platform/platform-developers/platform-sh-extensions.sh"
test -f $PF_SH_EXT && source $PF_SH_EXT

ct() {
	echo $1
	if [[ $# -eq 0 ]]; then
		cd "$REPO_HOME/ct/controltower"
		return;
	fi

	if [[ $1 = "developers" || $1 = "devs" ]]; then
		cd "$REPO_HOME/ct/ct-developers"
		return;
	fi

	if [[ $1 = "mobile" ]]; then
		cd "$REPO_HOME/ct/controltowermobile"
		return;
	fi

	if [[ $1 = "modules" ]]; then
		cd "$REPO_HOME/ct/ct-modules"
		return;
	fi

	cd "$REPO_HOME/ct/$1"
}

_ct_completions() {
  COMPREPLY=($(compgen -W "devs mobile modules" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _ct_completions ct

repo() {
	cd "$REPO_HOME/$1"
}

_repo_completions()
{
  COMPREPLY=($(compgen -W "$(ls $REPO_HOME | xargs -n 1 basename)" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _repo_completions repo

dp() {
	cd "$HOME/Repos/data-platform/$1"
}

_dp_completions()
{
  COMPREPLY=($(compgen -W "$(ls ~/Repos/data-platform | xargs -n 1 basename)" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _dp_completions dp

killgrep() {
	ps | grep "$*" | grep -v grep | awk -F' ' '{print $1}' | xargs kill
}

keep_alive() {
  while true; do
    "$@"
  done
}

anykey() {
	read -k1 -s REPLY\?"Press any key to execute \"$*\" "
	case "$REPLY" in 
		*) eval $*
		;; 
	esac
}

start() {
	eval $STARTCMD
}

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c="clear"
alias qemu="qemu-system-x86_64"
alias dcu="docker-compose up"
alias dcb="docker-compose build"
alias dcub="docker-compose up --build"
alias portfind="sudo netstat -nlp | grep"
alias pf="platform"
alias dppf="dp-prefect-port-forward"
alias dr="dotnet run"
alias pnpx="pnpm dlx"
alias python=python3
alias pip=pip3

zg() {
	filename=$(basename -- "$1")

	zip "$filename" "$1"

	gpg -c "$1.zip"
}

uzg() {
	gpg "$1"

	f=$1

	zipped=${f::-4}

	unzip $zipped
}

portpid() {
	sudo lsof -i -P | grep LISTEN | grep :$1
}

pidpath() {
	ps xuwww -p $1
}

aks-login() {
	az login && az account set --subscription "firebend-mca"
}

aks() {
	env=$1
	if 	 [ $env == 'qa'   ]; then rg='aks-qa';   cluster='qa-central';
	elif [ $env == 'west' ]; then rg='aks-prod'; cluster='prod-west';
	elif [ $env == 'east' ]; then rg='aks-prod'; cluster='prod-east';
	else echo 'invalid environment'; return 0; fi

	exec 7>&2 2>/dev/null && trap 'kill $(jobs -p) && exec 2>&7 7>&- && rm $fifoname && trap - SIGINT' SIGINT

	fifoname="/tmp/pipe_$RANDOM" && mkfifo $fifoname
	
	start "https://microsoft.com/devicelogin"

	head -n 1 $fifoname | sed -r 's/.*the code (.*) to.*/\1/' > /dev/clipboard 2>&1 & pid1=$!
	az aks get-credentials --overwrite-existing --resource-group $rg --name $cluster &> /dev/null && kubectl get po 2> $fifoname & pid2=$!

	wait $pid1 && echo "*** CODE IS COPIED TO THE CLIPBOARD ***" && wait $pid2
	
	exec 2>&7 7>&- && rm $fifoname && trap - SIGINT
}

aks-help() {
	echo "kubectl get po
kubectl delete po <pod_name>
kubectl logs <pod_name>
kubectl logs <pod_name> -f
kubectl logs <pod_name> | grep \"<search_term>\"
kubectl top pods"
}

source ~/.antigen.zsh

antigen bundle agkozak/zsh-z

antigen apply

if ! command -v starship &> /dev/null
then
    curl -fsSL https://starship.rs/install.sh | sh
fi

eval "$(starship init zsh)"

test -f ~/.zsh_custom && source ~/.zsh_custom
 
export PATH=$PATH:~/.yarn/bin

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export ASPNETCORE_ENVIRONMENT="Development"
export AZURE_FUNCTIONS_ENVIRONMENT="Development"

# Setting PATH for Python 3.5
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:${PATH}"
export PATH

eval "$(pyenv init --path)"
eval "$(pyenv init -)"

export PATH="/Users/terryschneider/.local/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/terryschneider/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# Add .NET Core SDK tools
export PATH="$PATH:/Users/terryschneider/.dotnet/tools"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


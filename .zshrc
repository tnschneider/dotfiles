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

dp-prefect-port-forward() {
	APOLLO_LOOP=0
	UI_LOOP=0
	
	on_exit() {
		kill $APOLLO_LOOP
		kill $UI_LOOP
		killall kubectl
	}

	trap on_exit SIGINT SIGTERM

	{
		while :
		do
			kubectl port-forward services/prefect-apollo 4200:4200 -n prefect &
			wait
		done   
	} &
	APOLLO_LOOP=$!

	{
		while :
		do
			kubectl port-forward services/prefect-ui 1234:8080 -n prefect &
			wait
		done   
	} &
	UI_LOOP=$!

	wait
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

# Setting PATH for Python 3.5
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
export PATH

eval "$(pyenv init --path)"
eval "$(pyenv init -)"

export PATH="/Users/terryschneider/.local/bin:$PATH"

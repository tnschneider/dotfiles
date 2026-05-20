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

# Load custom script per environment
test -f ~/.zsh_custom && source ~/.zsh_custom


###############
### ANTIGEN ###
###############

if [[ ! -f ~/.antigen.zsh ]]; then
	curl -L https://raw.githubusercontent.com/zsh-users/antigen/develop/bin/antigen.zsh > ~/.antigen.zsh
fi

source ~/.antigen.zsh

antigen bundle agkozak/zsh-z
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle MichaelAquilina/zsh-you-should-use
antigen bundle extract

antigen apply


################
### STARSHIP ###
################

if ! command -v starship &> /dev/null
then
    curl -fsSL https://starship.rs/install.sh | sh
fi

eval "$(starship init zsh)"


################
### ENV VARS ###
################

export ASPNETCORE_ENVIRONMENT="Development"
export AZURE_FUNCTIONS_ENVIRONMENT="Development"
export DOTNET_WATCH_RESTART_ON_RUDE_EDIT=1


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
alias portfind="sudo netstat -nlp | grep"
alias zshrc="source ~/.zshrc"
alias pidpath="ps xuwww -p"
alias portpid="sudo lsof -i -P | grep LISTEN | grep"
alias kadprod="kalp 5000"
alias kadqa="kalp 4000"
alias s="start"


#################
### FUNCTIONS ###
#################

## Utility Functions
kalp() {
  while true; do 
  	nc -z localhost $1; 
	sleep 10; 
  done 
}

killgrep() {
	local signal=""
	local pattern=""

	if [[ $1 == "-h" || $1 == "--help" ]]; then
		echo "Usage: killgrep [-signal] <pattern>"
		echo "  -h, --help    Show this help message and exit"
		echo "  -9            Send SIGKILL (force kill)"
		echo "  -15           Send SIGTERM (graceful, default)"
		echo "  -HUP          Send SIGHUP (hang up)"
		echo ""
		echo "Examples:"
		echo "  killgrep node       # Kill processes matching 'node' (SIGTERM)"
		echo "  killgrep -9 node    # Force kill processes matching 'node'"
		return
	fi

	if [[ -z $1 ]]; then
		echo "Usage: killgrep [-signal] <pattern>"
		return 1
	fi

	if [[ $1 == -* ]]; then
		signal="$1"
		shift
	fi
	pattern="$*"

	if [[ -z $pattern ]]; then
		echo "Error: no pattern specified"
		return 1
	fi

	local pids=$(pgrep -f "$pattern")
	if [[ -z $pids ]]; then
		echo "No matching processes found"
		return 1
	fi

	if [[ -n $signal ]]; then
		kill "$signal" $pids
	else
		kill $pids
	fi
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
	printf "$STARTCMD\n"
	eval $STARTCMD
}

printstart() {
	echo $STARTCMD
}

## Android Functions
android() {
	AVD=$1
	if [[ -z $AVD ]]; then
		AVD="TC-72"
	fi
    ~/Library/Android/sdk/emulator/emulator -avd $AVD
}

android-launch() {
	AVD=$1
	EMULATOR=$2
	APK_PATH=$3
	PACKAGE_NAME=$4
	~/Library/Android/sdk/emulator/emulator -avd $AVD > /dev/null 2>&1 &
	adb -s $EMULATOR wait-for-device
	BOOT_COMPLETED=""
	while [ "$BOOT_COMPLETED" != "1" ]; do
		BOOT_COMPLETED=$(adb -s $EMULATOR shell getprop sys.boot_completed | tr -d '\r')
		sleep 1
	done
	adb -s $EMULATOR install -r $APK_PATH > /dev/null 2>&1
	sleep 1
	adb -s $EMULATOR shell monkey -p $PACKAGE_NAME -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1 &
}

ct-mobile-launch() {
	android-launch "TC-72"\
		"emulator-5554"\
		~/Repos/walmart-control-tower/dist/mobile-app/src/ControlTowerMobile.Droid/net8.0-android/com.firebend.controltower-Signed.apk\
		"com.firebend.controltower" &
}

ct-mobile-launch-two() {
	android-launch "TC-72"\
		"emulator-5554"\
		~/Repos/walmart-control-tower/dist/mobile-app/src/ControlTowerMobile.Droid/net8.0-android/com.firebend.controltower-Signed.apk\
		"com.firebend.controltower" &

	android-launch "TC-72_2"\
		"emulator-5556"\
		~/Repos/walmart-control-tower/dist/mobile-app/src/ControlTowerMobile.Droid/net8.0-android/com.firebend.controltower-Signed.apk\
		"com.firebend.controltower" &
}

## Entity Framework Functions
ef() {
	if [[ -z $1 || $1 == "-h" || $1 == "--help" ]]; then
		echo "Usage: ef [migrations|mg|mga|database|db|dbu] [options]"
		echo "  -h, --help               Show this help message and exit"
		echo "  migrations, mg <args>    Run \`dotnet ef migrations <args>\`"
		echo "  mga <name>               Add a new migration with name <name>"
		echo "  database, db <args>      Run \`dotnet ef database <args>\`"
		echo "  dbu                      Update the database to the latest migration"
		echo "  dbu <args>               Run \`dotnet ef database update <args>\`"
		return
	fi

	if [[ $1 == "mg" || $1 == "migrations" ]]; then
		shift
		dotnet ef migrations "$@" 
		return;		
	fi

	if [[ $1 == "mga" ]]; then
		shift
		dotnet ef migrations add "$@"
		return;
	fi

	if [[ $1 == "db" || $1 == "database" ]]; then
		shift
		dotnet ef database "$@"
		return;
	fi

	if [[ $1 == "dbu" ]]; then
		shift
		dotnet ef database update "$@"
		return;
	fi

	dotnet ef "$@"
}


#####################
### NAV SHORTCUTS ###
#####################

REPO_HOME="$HOME/Repos"

# repos
repo() {
	cd "$REPO_HOME/$1"
}

_repo_completions()
{
  COMPREPLY=($(compgen -W "$(ls $REPO_HOME | xargs -n 1 basename)" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _repo_completions repo

# platform
PLATFORM_HOME="$REPO_HOME"
PF_SH_EXT="$PLATFORM_HOME/ct-platform/platform-developers/platform-sh-extensions.sh"
test -f $PF_SH_EXT && source $PF_SH_EXT

pf-api-sandbox() {
	cd "$PLATFORM_HOME/ct-platform/platform-developers/scripts/api-sandbox"
	export PF_DEFAULT_ENV="local"
	export PF_DEFAULT_WH="0103ed58-cf76-43a7-afdb-08de4349e37d"
}

# control tower legacy
ct() {
	if [[ $# -eq 0 ]]; then
		cd "$REPO_HOME/walmart-control-tower"
		return;
	fi

	if [[ $1 = "developers" || $1 = "devs" ]]; then
		cd "$REPO_HOME/walmart-control-tower/ct-developers"
		return;
	fi

	if [[ $1 = "mobile" ]]; then
		cd "$REPO_HOME/walmart-control-tower/mobile-app"
		return;
	fi

	if [[ $1 = "modules" ]]; then
		cd "$REPO_HOME/ct/ct-modules"
		return;
	fi

	if [[ $1 = "test" || $1 = "tests" ]]; then
		cd "$REPO_HOME/walmart-control-tower/ct-app/TrailerTracking.Test"
		return;
	fi

	if [[ $1 = "web" ]]; then
		cd "$REPO_HOME/walmart-control-tower/ct-app/TrailerTracking.Web"
		return;
	fi

	if [[ $1 = "worker" ]]; then
		cd "$REPO_HOME/walmart-control-tower/ct-app/TrailerTracking.Worker"
		return;
	fi

	if [[ $1 = "api-tests" ]]; then
		cd "$REPO_HOME/walmart-control-tower/ct-app/TrailerTracking.ApiTests"
		return;
	fi

	cd "$REPO_HOME/control-tower-walmart/$1"
}

_ct_completions() {
  COMPREPLY=($(compgen -W "devs mobile modules test web worker api-tests" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _ct_completions ct

# data pipelines
dp() {
	if [[ $# -eq 0 ]]; then
		cd "$REPO_HOME/data-pipelines"
		return;
	fi

	if [[ $1 = "walmart" ]]; then
		cd "$REPO_HOME/data-pipelines/ct-walmart-data-pipeline"
		return;
	fi

	if [[ $1 = "platform" ]]; then
		cd "$REPO_HOME/data-pipelines/platform-data-pipeline"
		return;
	fi

	if [[ $1 = "infra" ]]; then
		cd "$REPO_HOME/data-pipelines/firebend-dagster-infrastructure"
		return;
	fi

	cd "$REPO_HOME/data-pipelines/$1"
}



_dp_completions()
{
  COMPREPLY=($(compgen -W "walmart platform infra" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _dp_completions dp


####################
### BOOTSTRAP ###
####################

if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ $(uname -m) == "arm64" ]] && [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v git &> /dev/null; then
    brew install git || echo "Warning: Failed to install git"
fi

if ! command -v node &> /dev/null; then
    brew install node || echo "Warning: Failed to install node"
fi

if ! command -v dotnet &> /dev/null; then
    brew install --cask dotnet-sdk || echo "Warning: Failed to install dotnet-sdk"
fi

####################
### APPLICATIONS ###
####################
 
export PATH=$PATH:~/.yarn/bin


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Setting PATH for Python 3.5
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:${PATH}"
export PATH

eval "$(pyenv init --path)"
eval "$(pyenv init -)"

export PATH="$HOME/.local/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# Add .NET Core SDK tools
export PATH="$PATH:$HOME/.dotnet/tools"

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


# Added by Windsurf
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

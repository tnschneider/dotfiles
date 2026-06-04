HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=50000
bindkey -e

fpath=(~/.zsh $fpath)

autoload -Uz compinit

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
add-zsh-hook -D precmd _antigen_compinit
compinit -C


################
### STARSHIP ###
################

if ! command -v starship &> /dev/null
then
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
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
alias portfind="sudo lsof -i -P | grep"
alias zshrc="source ~/.zshrc"
alias pidpath="ps xuwww -p"
alias portpid="sudo lsof -i -P | grep LISTEN | grep"
alias s="start"
alias home="cd ~"


#################
### FUNCTIONS ###
#################

### Utility functions ###

# Kill processes by pattern: killgrep [-signal] <pattern>
killgrep() {
	local signal pattern pids
	[[ $1 == -[0-9]* || $1 == -[A-Z]* ]] && { signal=$1; shift; }
	pattern="$*"
	[[ -z $pattern ]] && { echo "Usage: killgrep [-signal] <pattern>"; return 1; }
	pids=$(pgrep -f "$pattern") || { echo "No matching processes found"; return 1; }
	kill ${signal:+"$signal"} ${(f)pids}
	printf "Killed processes matching '%s' with signal '%s':\n%s\n" "$pattern" "${signal:--TERM}" "${pids//$'\n'/, }"
}

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

### Android Functions ###

# Launch an Android emulator
android() {
	AVD=$1
	if [[ -z $AVD ]]; then
		AVD="TC-72"
	fi
    ~/Library/Android/sdk/emulator/emulator -avd $AVD
}

# Launch an Android app on an emulator
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

# Launch the Control Tower mobile app
ct-mobile-launch() {
	android-launch "TC-72"\
		"emulator-5554"\
		~/Repos/walmart-control-tower/dist/mobile-app/src/ControlTowerMobile.Droid/net8.0-android/com.firebend.controltower-Signed.apk\
		"com.firebend.controltower" &
}

# Launch two instances of the Control Tower mobile app
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

### Entity Framework Functions ###

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


#####################
### NAV SHORTCUTS ###
#####################

REPO_HOME="$HOME/Repos"

# repos
repo() {
	cd "$REPO_HOME/$1"
}

_repo_completions() {
  compadd -- "$REPO_HOME"/*(/:t)
}

compdef _repo_completions repo

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
  local -A dirs=(
    devs       "$REPO_HOME/walmart-control-tower/ct-developers"
    developers "$REPO_HOME/walmart-control-tower/ct-developers"
    mobile     "$REPO_HOME/walmart-control-tower/mobile-app"
    modules    "$REPO_HOME/ct/ct-modules"
    test       "$REPO_HOME/walmart-control-tower/ct-app/TrailerTracking.Test"
    tests      "$REPO_HOME/walmart-control-tower/ct-app/TrailerTracking.Test"
    web        "$REPO_HOME/walmart-control-tower/ct-app/TrailerTracking.Web"
    worker     "$REPO_HOME/walmart-control-tower/ct-app/TrailerTracking.Worker"
    api-tests  "$REPO_HOME/walmart-control-tower/ct-app/TrailerTracking.ApiTests"
  )
  [[ -n $1 ]] && cd "${dirs[$1]:-$REPO_HOME/control-tower-walmart/$1}" || cd "$REPO_HOME/walmart-control-tower"
}

_ct_completions() {
  compadd devs developers mobile modules test tests web worker api-tests
}

compdef _ct_completions ct

# data pipelines
dp() {
  local -A dirs=(
    walmart  "$REPO_HOME/data-pipelines/ct-walmart-data-pipeline"
    platform "$REPO_HOME/data-pipelines/platform-data-pipeline"
    infra    "$REPO_HOME/data-pipelines/firebend-dagster-infrastructure"
  )
  cd "${dirs[$1]:-$REPO_HOME/data-pipelines${1:+/$1}}"
}

_dp_completions() {
  compadd walmart platform infra
}

compdef _dp_completions dp

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

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Add .NET Core SDK tools
export PATH="$PATH:$HOME/.dotnet/tools"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# pnpm completion (includes package.json script names for `pnpm run`)
if command -v pnpm >/dev/null 2>&1; then
	eval "$(pnpm completion zsh)"
fi
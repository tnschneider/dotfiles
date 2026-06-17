# env vars
export MACHINE_NAME=$(hostname -s)
export ASPNETCORE_ENVIRONMENT="Development"
export AZURE_FUNCTIONS_ENVIRONMENT="Development"
export DOTNET_WATCH_RESTART_ON_RUDE_EDIT=1
export REPO_HOME="$HOME/Repos"

# brew
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# system python
export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:${PATH}"

# local bin
export PATH="$HOME/.local/bin:$PATH"

# snowflake cli
export PATH=/Applications/SnowflakeCLI.app/Contents/MacOS/:$PATH

# snowsql
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH

# yarn
export PATH=$PATH:~/.yarn/bin

# dotnet tools
export PATH="$PATH:$HOME/.dotnet/tools"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
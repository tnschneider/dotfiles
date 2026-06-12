#!/bin/zsh
set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

rm -f ~/.gitconfig && ln -s "$DOTFILES/.gitconfig" ~/.gitconfig
rm -f ~/.zshrc && ln -s "$DOTFILES/.zshrc" ~/.zshrc
rm -rf ~/.zsh && ln -s "$DOTFILES/.zsh" ~/.zsh
rm -rf ~/.zsh.fb && ln -s "$DOTFILES/.zsh.fb" ~/.zsh.fb

mkdir -p "$HOME/Library/Application Support/tabby"
rm -f "$HOME/Library/Application Support/tabby/config.yaml" \
    && ln -s "$DOTFILES/tabby/config.yaml" "$HOME/Library/Application Support/tabby/config.yaml"
rm -f "$HOME/Library/Application Support/tabby/workspace-config.yaml" \
    && ln -s "$DOTFILES/tabby/workspace-config.yaml" "$HOME/Library/Application Support/tabby/workspace-config.yaml"

### BOOTSTRAP ###

if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ $(uname -m) == "arm64" ]] && [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v git &> /dev/null; then
    brew install git || echo "Warning: Failed to install git"
fi

if [[ ! -d "$HOME/.nvm" ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    \. "$HOME/.nvm/nvm.sh"
    nvm install 20.19.6
    nvm install 22
    nvm alias default 20.19.6
fi

if ! command -v dotnet &> /dev/null; then
    curl -fsSL https://dot.net/v1/dotnet-install.sh | bash || echo "Warning: Failed to install dotnet-sdk"
fi

if ! command -v pyenv &> /dev/null; then
    brew install pyenv || echo "Warning: Failed to install pyenv"
    export PATH="$(brew --prefix pyenv)/shims:$(brew --prefix pyenv)/bin:$PATH"
    pyenv install -s 3.12
    pyenv global 3.12
fi

if ! command -v pnpm &> /dev/null; then
    brew install pnpm@10 || echo "Warning: Failed to install pnpm"
fi

if ! command -v az &> /dev/null; then
    brew install azure-cli || echo "Warning: Failed to install azure-cli"
fi

if ! command -v kubectl &> /dev/null; then
    brew install kubectl || echo "Warning: Failed to install kubectl"
fi

if ! command -v helm &> /dev/null; then
    brew install helm || echo "Warning: Failed to install helm"
fi

if command -v corepack &> /dev/null && ! command -v yarn &> /dev/null; then
    corepack enable yarn || echo "Warning: Failed to enable yarn via corepack"
fi

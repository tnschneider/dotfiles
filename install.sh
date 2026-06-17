#!/bin/

# This script sets up symlinks for configuration files and bootstraps essential tools and applications.
set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# configs and extensions
rm -f ~/.gitconfig && ln -s "$DOTFILES/.gitconfig" ~/.gitconfig
rm -f ~/.zprofile && ln -s "$DOTFILES/.zprofile" ~/.zprofile
rm -f ~/.zshrc && ln -s "$DOTFILES/.zshrc" ~/.zshrc
rm -rf ~/.zsh && ln -s "$DOTFILES/.zsh" ~/.zsh

# tabby
mkdir -p "$HOME/Library/Application Support/tabby"
rm -f "$HOME/Library/Application Support/tabby/config.yaml" \
    && ln -s "$DOTFILES/tabby/config.yaml" "$HOME/Library/Application Support/tabby/config.yaml"
rm -f "$HOME/Library/Application Support/tabby/workspace-config.yaml" \
    && ln -s "$DOTFILES/tabby/workspace-config.yaml" "$HOME/Library/Application Support/tabby/workspace-config.yaml"

# brew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ $(uname -m) == "arm64" ]] && [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# git
if ! command -v git &> /dev/null; then
    brew install git || echo "Warning: Failed to install git"
fi

# antigen
if [[ ! -f ~/.antigen.zsh ]]; then
    curl -fsSL https://raw.githubusercontent.com/zsh-users/antigen/master/bin/antigen.zsh -o ~/.antigen.zsh \
        || echo "Warning: Failed to install antigen"
fi

# starship
if ! command -v starship &> /dev/null; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes || echo "Warning: Failed to install starship"
fi

# fnm/node
if ! command -v fnm &> /dev/null; then
    brew install fnm || echo "Warning: Failed to install fnm"
fi
if command -v fnm &> /dev/null; then
    eval "$(fnm env)"
    fnm install 20.19.6 || echo "Warning: Failed to install Node 20.19.6"
    fnm install 22 || echo "Warning: Failed to install Node 22"
    fnm default 20.19.6 || echo "Warning: Failed to set default Node version to 20.19.6"
fi

# dotnet
if ! command -v dotnet &> /dev/null; then
    curl -fsSL https://dot.net/v1/dotnet-install.sh | bash || echo "Warning: Failed to install dotnet-sdk"
fi

# ef
if ! command -v dotnet-ef &> /dev/null; then
    dotnet tool install --global dotnet-ef || echo "Warning: Failed to install dotnet-ef"
fi

# dotnet-dump
if ! command -v dotnet-dump &> /dev/null; then
    dotnet tool install --global dotnet-dump || echo "Warning: Failed to install dotnet-dump"
fi

# sqlpackage
if ! command -v sqlpackage &> /dev/null; then
    dotnet tool install --global microsoft.sqlpackage || echo "Warning: Failed to install Microsoft.SqlPackage"
fi

# roslynator
if ! command -v roslynator &> /dev/null; then
    dotnet tool install --global roslynator.dotnet.cli || echo "Warning: Failed to install roslynator.dotnet.cli"
fi

# pyenv/python
if ! command -v pyenv &> /dev/null; then
    brew install pyenv || echo "Warning: Failed to install pyenv"
fi
if command -v pyenv &> /dev/null; then
    export PATH="$(brew --prefix pyenv)/shims:$(brew --prefix pyenv)/bin:$PATH"
    pyenv install -s 3.12
    pyenv global 3.12
fi

# pnpm
if ! command -v pnpm &> /dev/null; then
    brew install pnpm@10 || echo "Warning: Failed to install pnpm"
fi

# azure-cli
if ! command -v az &> /dev/null; then
    brew install azure-cli || echo "Warning: Failed to install azure-cli"
fi

# kubectl
if ! command -v kubectl &> /dev/null; then
    brew install kubectl || echo "Warning: Failed to install kubectl"
fi

# yarn
if command -v corepack &> /dev/null && ! command -v yarn &> /dev/null; then
    corepack enable yarn || echo "Warning: Failed to enable yarn via corepack"
fi

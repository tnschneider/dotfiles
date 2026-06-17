#!/bin/bash

# This script installs all applications defined in the Brewfile.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew &>/dev/null; then
    echo "[ERROR] Homebrew is not installed. Please run install.sh or source ~/.zshrc first."
    exit 1
fi

brew trust microsoft/mssql-release
brew trust mongodb/brew

echo "[INFO] Installing applications from Brewfile..."
HOMEBREW_ACCEPT_EULA=Y brew bundle --file="$SCRIPT_DIR/Brewfile"
echo "[SUCCESS] Installation completed!"

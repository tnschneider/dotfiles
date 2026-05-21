#!/bin/bash

# Application Installation Script
# This script installs all applications defined in the Brewfile.
# Install everything with: brew bundle

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew &>/dev/null; then
    echo "[ERROR] Homebrew is not installed. Please run install.sh or source ~/.zshrc first."
    exit 1
fi

echo "[INFO] Installing applications from Brewfile..."
brew bundle --file="$SCRIPT_DIR/Brewfile"
echo "[SUCCESS] Installation completed!"

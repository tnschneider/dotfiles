#!/bin/bash

# Application Installation Script
# This script installs a comprehensive set of applications for macOS

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install application via Homebrew
install_brew_app() {
    local brew_formula="$1"
    
    if brew list "$brew_formula" &>/dev/null; then
        print_success "$brew_formula already installed"
    else
        print_status "Installing $brew_formula..."
        if brew install "$brew_formula"; then
            print_success "$brew_formula installed successfully"
        else
            print_error "Failed to install $brew_formula"
            return 1
        fi
    fi
}

# Function to install cask application via Homebrew
install_cask_app() {
    local cask_name="$1"
    
    if brew list --cask "$cask_name" &>/dev/null; then
        print_success "$cask_name already installed"
    else
        print_status "Installing $cask_name..."
        if brew install --cask "$cask_name"; then
            print_success "$cask_name installed successfully"
        else
            print_error "Failed to install $cask_name"
            return 1
        fi
    fi
}

# Main installation function
main() {
    print_status "Starting application installation..."

    if ! command_exists brew; then
        print_error "Homebrew is not installed. Please run install.sh or source ~/.zshrc first."
        exit 1
    fi
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    print_status "Installing applications via Homebrew..."

    print_status "Installing cask apps..."
    while IFS= read -r cask || [[ -n "$cask" ]]; do
        [[ -z "$cask" || "$cask" == \#* ]] && continue
        install_cask_app "$cask"
    done < "$SCRIPT_DIR/casks.txt"

    print_status "Installing formula apps..."
    while IFS= read -r formula || [[ -n "$formula" ]]; do
        [[ -z "$formula" || "$formula" == \#* ]] && continue
        install_brew_app "$formula"
    done < "$SCRIPT_DIR/formulas.txt"
    
    print_success "Installation completed!"
}

# Run main function
main "$@"

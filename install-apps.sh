#!/bin/bash
set -e

# Application Installation Script
# This script installs a comprehensive set of applications for macOS

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
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
    local app_name="$1"
    local brew_formula="$2"
    
    if brew list "$brew_formula" &>/dev/null; then
        print_success "$app_name already installed"
    else
        print_status "Installing $app_name..."
        if brew install "$brew_formula"; then
            print_success "$app_name installed successfully"
        else
            print_error "Failed to install $app_name"
            return 1
        fi
    fi
}

# Function to install cask application via Homebrew
install_cask_app() {
    local app_name="$1"
    local cask_name="$2"
    
    if brew list --cask "$cask_name" &>/dev/null; then
        print_success "$app_name already installed"
    else
        print_status "Installing $app_name..."
        if brew install --cask "$cask_name"; then
            print_success "$app_name installed successfully"
        else
            print_error "Failed to install $app_name"
            return 1
        fi
    fi
}

# Function to show manual download instructions
show_manual_download() {
    local app_name="$1"
    local url="$2"
    
    print_warning "$app_name requires manual installation"
    echo "  Please download from: $url"
    echo "  After downloading, open the .dmg file and drag to Applications folder"
    echo ""
}

# Main installation function
main() {
    print_status "Starting application installation..."

    if ! command_exists brew; then
        print_error "Homebrew is not installed. Please run install.sh or source ~/.zshrc first."
        exit 1
    fi
    
    print_status "Installing applications via Homebrew..."
    
    # Development Tools
    print_status "Installing Development Tools..."
    install_cask_app "Visual Studio Code" "visual-studio-code"
    install_cask_app "Windsurf" "windsurf"
    install_cask_app "Sublime Text" "sublime-text"
    install_cask_app "Sublime Merge" "sublime-merge"
    install_cask_app "Android Studio" "android-studio"
    install_cask_app "Docker" "docker"
    install_cask_app "Postman" "postman"
    install_cask_app "DataGrip" "datagrip"
    install_cask_app "Rider" "rider"
    install_brew_app "Python 3.12" "python@3.12"
    install_cask_app "Tabby" "tabby"
    install_cask_app "Redis Insight" "redis-insight"
    install_cask_app "Lens" "lens"
    
    # Browsers
    print_status "Installing Browsers..."
    install_cask_app "Firefox" "firefox"
    install_cask_app "Brave Browser" "brave-browser"
    
    # Communication
    print_status "Installing Communication Apps..."
    install_cask_app "Slack" "slack"
    install_cask_app "Telegram" "telegram"
    install_cask_app "Zoom" "zoom"
    install_cask_app "Microsoft Teams" "microsoft-teams"
    
    # Microsoft Office
    print_status "Installing Microsoft Office..."
    install_cask_app "Microsoft Excel" "microsoft-excel"
    install_cask_app "Microsoft Word" "microsoft-word"
    install_cask_app "Microsoft PowerPoint" "microsoft-powerpoint"
    install_cask_app "Microsoft Outlook" "microsoft-outlook"
    
    # Productivity Utilities
    print_status "Installing Productivity Utilities..."
    install_cask_app "Rectangle" "rectangle"
    install_cask_app "Alfred" "alfred"
    install_cask_app "KeepingYouAwake" "keepingyouawake"
    install_cask_app "The Unarchiver" "the-unarchiver"
    install_cask_app "Bitwarden" "bitwarden"
    install_cask_app "Todoist" "todoist"
    install_cask_app "Spotify" "spotify"
    install_cask_app "CleanShot X" "cleanshot"
    install_cask_app "Cold Turkey Blocker" "cold-turkey-blocker"
    install_cask_app "DisplayLink Manager" "displaylink"
    install_cask_app "Studio3T" "studio-3t"
    install_cask_app "Apidog" "apidog"
    
    print_success "Installation completed!"
    echo ""
    print_status "Summary:"
    echo "  - All applications have been installed via Homebrew"
    echo "  - Restart your terminal to ensure all PATH changes take effect"
    echo "  - Some applications may need to be launched once to complete setup"
    echo ""
    print_status "Next steps:"
    echo "  1. Configure Alfred, Rectangle, and other utilities as needed"
    echo "  2. Set up your development environments (Android SDK, Docker, etc.)"
    echo "  3. Sign in to Microsoft Office and other account-based applications"
}

# Run main function
main "$@"

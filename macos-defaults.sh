#!/bin/bash

# This script applies macOS system preferences.
# Many settings require a logout/restart to take effect.

set -e

echo "Applying macOS preferences..."


#####################
### KEYBOARD      ###
#####################

# Swap Cmd and Ctrl on all keyboards (all keyboards = vendor -1, product -1)
# Key modifier values: 0=none, 2=Ctrl, 4=Option, 8=Cmd, 16=Fn
# This maps: Ctrl (0x700000064) -> Cmd, Cmd (0x7000000e3) -> Ctrl
defaults write -g NSUserKeyEquivalents '{}'
/usr/bin/hidutil property --set '{
  "UserKeyMapping": [
    {
      "HIDKeyboardModifierMappingSrc": 30064771299,
      "HIDKeyboardModifierMappingDst": 30064771298
    },
    {
      "HIDKeyboardModifierMappingSrc": 30064771298,
      "HIDKeyboardModifierMappingDst": 30064771299
    }
  ]
}'
# NOTE: hidutil mappings are ephemeral (reset on reboot).
# To persist across reboots, a launchd plist is needed (see below).

HIDUTIL_PLIST="$HOME/Library/LaunchAgents/com.user.hidutil-keyremap.plist"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$HIDUTIL_PLIST" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.hidutil-keyremap</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771298},{"HIDKeyboardModifierMappingSrc":30064771298,"HIDKeyboardModifierMappingDst":30064771299}]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
launchctl load "$HIDUTIL_PLIST" 2>/dev/null || launchctl bootstrap gui/$(id -u) "$HIDUTIL_PLIST" 2>/dev/null || true
echo "Key swap (Cmd <-> Ctrl) applied and persisted via launchd."

# Key repeat rate (lower = faster; default 6)
defaults write -g KeyRepeat -int 2

# Delay before key repeat starts (lower = shorter; default 25)
defaults write -g InitialKeyRepeat -int 15

# Disable press-and-hold accent popup (enables key repeat for all keys)
defaults write -g ApplePressAndHoldEnabled -bool false


#####################
### TRACKPAD      ###
#####################

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write -g com.apple.mouse.tapBehavior -int 1

# Enable three-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true


#####################
### DOCK          ###
#####################

# Don't auto-hide the Dock
defaults write com.apple.dock autohide -bool false

# Remove the auto-hide delay
defaults write com.apple.dock autohide-delay -float 0

# Speed up the hide/show animation
defaults write com.apple.dock autohide-time-modifier -float 0.25

# Don't show recent apps in Dock
defaults write com.apple.dock show-recents -bool false

# Minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true


#####################
### FINDER        ###
#####################

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true


#####################
### SCREEN        ###
#####################

# Save screenshots to Downloads
defaults write com.apple.screencapture location -string "$HOME/Downloads"

# Save screenshots as PNG
defaults write com.apple.screencapture type -string "png"

# Disable screenshot shadow
defaults write com.apple.screencapture disable-shadow -bool true


#####################
### MISC          ###
#####################

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Show battery percentage in menu bar
defaults write com.apple.menuextra.battery ShowPercent -string "YES"


#####################
### RESTART       ###
#####################

echo "Done. Restarting affected apps..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
echo "Complete. Some settings may require a full logout/restart."

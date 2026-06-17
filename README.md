# dotfiles

```bash
git clone <repository-url>
cd dotfiles
./install.sh
./install-apps.sh
./macos-defaults.sh
```

1. **`install.sh`** — symlinks dotfiles to home directory and bootstraps essential apps
    - removes existing .gitconfig, .zprofile, .zshrc, .zsh/, and Tabby config if exists
2. **`install-apps.sh`** — installs Homebrew apps from `Brewfile`
3. **`macos-defaults.sh`** — applies macOS system preferences

# dotfiles

```bash
git clone [<repository-url>](https://github.com/tnschneider/dotfiles)
cd dotfiles

# symlinks dotfiles to home directory and bootstraps essential apps
# removes existing .gitconfig, .zprofile, .zshrc, .zsh/, and Tabby config if exists
./install.sh

# installs Homebrew apps from `Brewfile`
./install-apps.sh

# applies macOS system preferences
./macos-defaults.sh
```

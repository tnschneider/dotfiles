# dotfiles

## Setup

```bash
git clone <repository-url>
cd dotfiles
./install.sh
```

Creates symlinks from your home directory to the tracked dotfiles:

- `~/.gitconfig`
- `~/.zshrc`
- `~/Library/Application Support/tabby/config.yaml`
- `~/Library/Application Support/tabby/workspace-config.yaml`

## Scripts

### `install-apps.sh`

Installs all applications and formulae defined in `Brewfile` via `brew bundle`.

```bash
./install-apps.sh
```

### `macos-defaults.sh`

Applies macOS system preferences. Run once on a fresh machine (separate from `install.sh` since it restarts Finder and Dock).

```bash
./macos-defaults.sh
```

Covers:

- **Keyboard** — Cmd↔Ctrl swap (persisted via launchd), faster key repeat
- **Trackpad** — Tap to click, three-finger drag
- **Dock** — Auto-hide off, no recent apps, minimize into app icon
- **Finder** — Show extensions, hidden files, path bar, list view by default
- **Screenshots** — Saved to `~/Downloads` as PNG, no shadow

## Files

| File | Description |
| ---- | ----------- |
| `.zshrc` | Zsh config — aliases, functions, PATH, antigen plugins, starship |
| `.gitconfig` | Git config — aliases, merge/diff tools, credential helper |
| `Brewfile` | All Homebrew casks and formulae (`brew bundle` to install) |
| `tabby/config.yaml` | Tabby terminal config |
| `tabby/workspace-config.yaml` | Tabby workspace config |

## Adding new apps

Edit `Brewfile` directly, or dump your current Homebrew state with:

```bash
brew bundle dump --force
```

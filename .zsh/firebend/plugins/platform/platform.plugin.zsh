export PLATFORM_HOME="${PLATFORM_HOME:-${REPO_HOME:-$HOME/Repos}}"

# Defer sourcing until the first precmd so that antigen apply has already
# called compinit. At that point _comps is set, platform-sh-extensions.sh
# skips its own compinit -C call, and compdef runs against the live
# completion system instead of being wiped by a later compinit.
_platform_init() {
  local ext="$PLATFORM_HOME/ct-platform/platform-developers/platform-sh-extensions.sh"
  [[ -f "$ext" ]] && source "$ext"
  [[ -f "$ext" ]] || echo "Warning: platform-sh-extensions.sh not found at $ext, set PLATFORM_HOME"
  add-zsh-hook -d precmd _platform_init
  unfunction _platform_init 2>/dev/null
}
add-zsh-hook precmd _platform_init
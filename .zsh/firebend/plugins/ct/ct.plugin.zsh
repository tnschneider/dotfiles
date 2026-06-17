#!/usr/bin/env zsh

_plugin_dir="${0:A:h}"
fpath=("$_plugin_dir" $fpath)
autoload -Uz ct _ct ct-mobile-launch

if (( $+functions[compdef] )); then
  compdef _ct ct
fi

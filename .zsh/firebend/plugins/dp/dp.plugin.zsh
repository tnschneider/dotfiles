#!/usr/bin/env zsh

_plugin_dir="${0:A:h}"
fpath=("$_plugin_dir" $fpath)
autoload -Uz dp _dp

if (( $+functions[compdef] )); then
  compdef _dp dp
fi

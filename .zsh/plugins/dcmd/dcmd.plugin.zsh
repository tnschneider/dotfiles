#!/usr/bin/env zsh

_plugin_dir="${0:A:h}"
fpath=("$_plugin_dir" $fpath)
autoload -Uz dcmd _dcmd

if (( $+functions[compdef] )); then
  compdef _dcmd dcmd
fi

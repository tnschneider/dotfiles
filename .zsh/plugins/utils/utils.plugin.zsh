#!/usr/bin/env zsh

_plugin_dir="${0:A:h}"
fpath=("$_plugin_dir" $fpath)
autoload -Uz anykey keepalive profile repo _repo

if (( $+functions[compdef] )); then
  compdef _repo repo
fi

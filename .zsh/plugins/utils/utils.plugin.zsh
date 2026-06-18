#!/usr/bin/env zsh

_plugin_dir="${0:A:h}"
fpath=("$_plugin_dir" $fpath)
autoload -Uz anykey keepalive profile repo _repo tzconv _tzconv

if (( $+functions[compdef] )); then
  compdef _repo repo
  compdef _tzconv tzconv
fi

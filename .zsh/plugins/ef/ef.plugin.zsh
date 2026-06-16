_ef_plugin_dir="${0:A:h}"
fpath=("$_ef_plugin_dir" $fpath)
autoload -Uz ef _ef

if (( $+functions[compdef] )); then
  compdef _ef ef
fi

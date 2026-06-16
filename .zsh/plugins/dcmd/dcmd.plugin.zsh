# Local Antigen bundle for dcmd.
_dcmd_plugin_dir="${0:A:h}"
fpath=("$_dcmd_plugin_dir" $fpath)
autoload -Uz dcmd _dcmd

if (( $+functions[compdef] )); then
  compdef _dcmd dcmd
fi

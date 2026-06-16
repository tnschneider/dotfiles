_repo_plugin_dir="${0:A:h}"
fpath=("$_repo_plugin_dir" $fpath)
autoload -Uz repo _repo

if (( $+functions[compdef] )); then
  compdef _repo repo
fi

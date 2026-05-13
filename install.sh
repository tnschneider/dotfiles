DOTFILES=`dirname "$(readlink -f "$0")"`

rm -f ~/.gitconfig && ln -s "$DOTFILES/.gitconfig" ~/.gitconfig
rm -f ~/.zshrc && ln -s "$DOTFILES/.zshrc" ~/.zshrc

mkdir -p "$HOME/Library/Application Support/tabby"
rm -f "$HOME/Library/Application Support/tabby/config.yaml" && ln -s "$DOTFILES/tabby/config.yaml" "$HOME/Library/Application Support/tabby/config.yaml"
rm -f "$HOME/Library/Application Support/tabby/workspace-config.yaml" && ln -s "$DOTFILES/tabby/workspace-config.yaml" "$HOME/Library/Application Support/tabby/workspace-config.yaml"
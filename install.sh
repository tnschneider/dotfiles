DOTFILES=`dirname $(readlink -f $0)`

rm -f ~/.gitconfig && ln -s $DOTFILES/.gitconfig ~/.gitconfig
rm -f ~/.bashrc && ln -s $DOTFILES/.bashrc ~/.bashrc
rm -f ~/.zshrc && ln -s $DOTFILES/.zshrc ~/.zshrc
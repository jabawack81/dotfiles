# Dotfiles

dot files managed via stow, for easy installation

 * install stow
  * `sudo pacman -S stow`
  * `brew install stow`
 * link the files by running `stow .` from inside the directory

## Vimrc

to install all the plugin use: [Vundle.vim](https://github.com/VundleVim/Vundle.vim) by:
 * `git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim` 
 * `vim +PluginInstall +qall`
 
## Tmuxrc

 * `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
 * open tmux and `prefix` + `I`

## Neovim
 * install neovim
 * open neovim and `space` then `l` for the lazyvim window then `S` to sync all the plugins

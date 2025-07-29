# Neovim Plugin Update Aliases
# Quick shortcuts for updating Neovim plugins

alias nvim-update="$HOME/.dotfiles/update-nvim-plugins.sh"
alias nvu="$HOME/.dotfiles/update-nvim-plugins.sh"
alias lazy-update="$HOME/.dotfiles/update-nvim-plugins.sh"

# Alternative paths in case dotfiles are in different location
if [[ -f "$HOME/dotfiles/update-nvim-plugins.sh" ]]; then
    alias nvim-update="$HOME/dotfiles/update-nvim-plugins.sh"
    alias nvu="$HOME/dotfiles/update-nvim-plugins.sh"
    alias lazy-update="$HOME/dotfiles/update-nvim-plugins.sh"
fi
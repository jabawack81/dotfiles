# Shortcuts for the dotfiles' Neovim plugin updater script.

_NVIM_UPDATE_SCRIPT="$HOME/dotfiles/scripts/update-nvim-plugins.sh"

if [[ -x "$_NVIM_UPDATE_SCRIPT" ]]; then
  alias nvim-update="$_NVIM_UPDATE_SCRIPT"
  alias nvu="$_NVIM_UPDATE_SCRIPT"
  alias lazy-update="$_NVIM_UPDATE_SCRIPT"
fi

unset _NVIM_UPDATE_SCRIPT

# Hostname-aware fastfetch via the dotfiles config selector.
# Also aliases the older `neofetch` name to the same script.
#
# The script lives in common/scripts (symlinked to ~/.config/scripts) because
# ~/.config/fastfetch points at the machine-specific config directory on
# personal machines, which does not contain it.
#
# Only defined where the script is actually present (not on servers), so
# .zshrc's check does not resolve to a dead alias.

if [[ -x "$HOME/.config/scripts/fastfetch-select.sh" ]]; then
  alias fastfetch='~/.config/scripts/fastfetch-select.sh'
  alias neofetch='~/.config/scripts/fastfetch-select.sh'
fi

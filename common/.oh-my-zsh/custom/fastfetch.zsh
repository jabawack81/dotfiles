# Hostname-aware fastfetch via the dotfiles config selector.
# Also aliases the older `neofetch` name to the same script.
# Only defined where the fastfetch config is linked (not on servers), so
# .zshrc's `command -v fastfetch` check does not resolve to a dead alias.

if [[ -x "$HOME/.config/fastfetch/select-config.sh" ]]; then
  alias fastfetch='~/.config/fastfetch/select-config.sh'
  alias neofetch='~/.config/fastfetch/select-config.sh'
fi

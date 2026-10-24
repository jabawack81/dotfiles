# Shortcuts for the tmux-claude launcher script.
# `tc`  — start a new tmux session running claude
# `tcc` — same, but continue the previous claude session
# `tcn` — pick (or create) a named claude session for this directory,
#         in a tmux session of the same name

alias tc='tmux-claude.sh'
alias tcc='tmux-claude.sh --continue'
alias tcn='tmux-claude.sh --pick'

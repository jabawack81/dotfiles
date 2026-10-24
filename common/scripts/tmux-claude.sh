#!/bin/bash

# tmux-claude.sh - Start tmux and optionally continue Claude session
# Usage: tmux-claude.sh [--continue|-c|--pick|-p]

MODE=plain

usage() {
    echo "Usage: tmux-claude.sh [--continue|-c|--pick|-p]"
    echo ""
    echo "Options:"
    echo "  --continue, -c    Start tmux and continue previous Claude session"
    echo "  --pick, -p        Pick a Claude session for this directory (or start"
    echo "                    a new named one) in a tmux session of the same name"
    echo "  --help, -h        Show this help message"
    echo ""
    echo "Without options, just starts tmux normally."
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --continue|-c)
            MODE=continue
            shift
            ;;
        --pick|-p)
            MODE=pick
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Attach to a tmux session, or switch to it when already inside tmux
# (attaching from inside would nest sessions).
tmux_enter() {
    if [[ -n "${TMUX:-}" ]]; then
        tmux switch-client -t "=$1"
    else
        tmux attach-session -t "=$1"
    fi
}

# Print "id<TAB>title<TAB>date" for each Claude session of this directory,
# newest first. Claude stores transcripts under ~/.claude/projects/ in a
# folder named after the path with / and . turned into -. The title is the
# last /rename (custom-title), else Claude's auto title (ai-title). This
# reads Claude's internal transcript format, so it may need updating when
# Claude Code changes it.
list_sessions() {
    local dir="$HOME/.claude/projects/$(pwd -P | sed 's#[/.]#-#g')"
    [[ -d "$dir" ]] || return 0

    local f title
    while IFS= read -r f; do
        # Skip sessions that never got a prompt (e.g. aborted starts).
        grep -q '"type":"user"' "$f" || continue
        title=$(grep -o '"customTitle":"[^"]*"' "$f" | tail -1 | cut -d'"' -f4)
        [[ -z "$title" ]] && title=$(grep -o '"aiTitle":"[^"]*"' "$f" | tail -1 | cut -d'"' -f4)
        printf '%s\t%s\t%s\n' "$(basename "$f" .jsonl)" "${title:-(untitled)}" \
            "$(date -r "$f" '+%Y-%m-%d %H:%M')"
    done < <(ls -t "$dir"/*.jsonl 2>/dev/null)
}

# Ask for a session name, defaulting to $1. Restricted to characters that
# are safe both as a tmux session name and inside the claude command sent
# with send-keys, and must not already belong to a session in $taken (one
# name per line), or tmux and `claude --resume <name>` could pick the wrong
# one.
ask_name() {
    local name
    while :; do
        # No `read -i` prefill: macOS ships bash 3.2, which lacks it.
        read -r -e -p "Session name [$1]: " name || exit 1
        name=${name:-$1}
        if [[ ! "$name" =~ ^[A-Za-z0-9_-]+$ ]]; then
            echo "Use letters, digits, - and _ only." >&2
        elif grep -qxF -- "$name" <<<"$taken"; then
            echo "\"$name\" is already used by another session here." >&2
        else
            break
        fi
    done
    echo "$name"
}

pick() {
    command -v fzf >/dev/null || { echo "fzf is not installed"; exit 1; }

    # One row per session: id (hidden), marker + title padded so the dates
    # line up, date. printf rather than `column -o`, which BSD/macOS lacks.
    local rows id title when mark taken=""
    rows=$'new\t+ new session'
    while IFS=$'\t' read -r id title when; do
        mark="  "
        tmux has-session -t "=$title" 2>/dev/null && mark="● "
        rows+=$'\n'$(printf '%s\t%s%-40.40s\t%s' "$id" "$mark" "$title" "$when")
        taken+="$title"$'\n'
    done < <(list_sessions)

    local choice
    choice=$(printf '%s\n' "$rows" |
        fzf --delimiter=$'\t' --with-nth=2.. --no-sort --reverse --height=40% \
            --header="Claude sessions in $(basename "$PWD")  (● = tmux running)")
    # fzf exits 1 (no match) or 130 (Esc / Ctrl-C) when you back out; anything
    # else is a real failure that would otherwise end the script silently.
    local rc=$?
    case $rc in
        0) ;;
        1|130) exit 0 ;;
        *) echo "fzf failed (exit $rc)" >&2; exit 1 ;;
    esac
    id=$(cut -f1 <<<"$choice" | tr -d ' ')
    title=$(cut -f2 <<<"$choice" | sed 's/^[●+ ] *//; s/ *$//')

    local default name cmd
    default="$(uname -n | cut -d. -f1)-$(basename "$PWD" | tr -c 'A-Za-z0-9_\n-' '-')"
    # Another session here already has it: suggest <host>-<dir>-2, -3, ...
    local base=$default n=2
    while grep -qxF -- "$default" <<<"$taken"; do
        default="$base-$n"
        n=$((n + 1))
    done
    if [[ "$id" == "new" ]]; then
        name=$(ask_name "$default") || exit 0
        cmd="claude --name $name"
    else
        # Named sessions keep their name; unnamed ones get one now so tmux
        # and Claude match next time.
        if [[ "$title" =~ ^[A-Za-z0-9_-]+$ ]]; then
            name=$title
        else
            name=$(ask_name "$default") || exit 0
        fi
        cmd="claude --resume $id --name $name"
    fi

    if tmux has-session -t "=$name" 2>/dev/null; then
        tmux_enter "$name"
        return
    fi
    # Run claude via send-keys so the pane drops back to a shell on exit.
    tmux new-session -d -s "$name" -c "$PWD"
    tmux send-keys -t "=$name:" "$cmd" Enter
    tmux_enter "$name"
}

if [[ "$MODE" == pick ]]; then
    pick
    exit
fi

# Start tmux (will attach to existing session or create new one)
if tmux has-session 2>/dev/null; then
    echo "Attaching to existing tmux session..."
    if [[ "$MODE" == continue ]]; then
        tmux attach-session \; send-keys 'claude --resume' Enter
    else
        tmux attach-session
    fi
else
    echo "Creating new tmux session..."
    if [[ "$MODE" == continue ]]; then
        tmux new-session -d \; send-keys 'claude --resume' Enter \; attach-session
    else
        tmux new-session
    fi
fi

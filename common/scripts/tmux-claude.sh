#!/bin/bash

# tmux-claude.sh - Start tmux and optionally continue Claude session
# Usage: tmux-claude.sh [--continue|-c]

CONTINUE_FLAG=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --continue|-c)
            CONTINUE_FLAG=true
            shift
            ;;
        --help|-h)
            echo "Usage: tmux-claude.sh [--continue|-c]"
            echo ""
            echo "Options:"
            echo "  --continue, -c    Start tmux and continue previous Claude session"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Without --continue, just starts tmux normally."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Start tmux (will attach to existing session or create new one)
if tmux has-session 2>/dev/null; then
    echo "Attaching to existing tmux session..."
    if [ "$CONTINUE_FLAG" = true ]; then
        tmux attach-session \; send-keys 'claude --resume' Enter
    else
        tmux attach-session
    fi
else
    echo "Creating new tmux session..."
    if [ "$CONTINUE_FLAG" = true ]; then
        tmux new-session -d \; send-keys 'claude --resume' Enter \; attach-session
    else
        tmux new-session
    fi
fi
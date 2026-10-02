#!/usr/bin/env bash
# Deploy the greeter to /etc/greetd and read back what it did.
#
# The greeter can only be tested by logging in, which means the evidence
# lands on a VT that greetd takes back a moment later. Every round of this
# has turned on two questions: did the file actually reach /etc/greetd, and
# what did the session say before it died. This answers both, so neither
# has to be taken on trust again.
#
#   greeter.sh deploy   copy to /etc/greetd, verify byte-for-byte, restart
#   greeter.sh logs     greetd's view of the last login, Hyprland's log
#   greeter.sh status   what is deployed right now, and is it current

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST="${HOSTNAME:-$(uname -n)}"
SRC="$REPO/$HOST/greetd"
DEST=/etc/greetd

RED=$'\e[31m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; BOLD=$'\e[1m'; DIM=$'\e[2m'; RESET=$'\e[0m'

say()  { printf '%s%s%s\n' "$BOLD" "$1" "$RESET"; }
ok()   { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
bad()  { printf '  %s✗%s %s\n' "$RED" "$RESET" "$1"; }
note() { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }

[ -d "$SRC" ] || { bad "no greetd config for '$HOST' at $SRC"; exit 1; }

# Compare a repo file with its deployed copy. Prints the verdict and returns
# non-zero when they differ, so a stale deploy can never pass unnoticed.
compare() {
    local rel="$1" src="$SRC/$1" dst="$DEST/$1"
    if [ ! -e "$dst" ]; then
        bad "$rel — not deployed"
        return 1
    elif cmp -s "$src" "$dst"; then
        ok "$rel — identical"
    else
        bad "$rel — DIFFERS from the repo"
        return 1
    fi
}

cmd_deploy() {
    say "Deploying $HOST greeter to $DEST"
    sudo install -o root -g root -m 0644 "$SRC/config.toml" "$DEST/config.toml"
    sudo install -d -o root -g root -m 0755 "$DEST/greeter"
    sudo install -o root -g root -m 0644 "$SRC/greeter/shell.qml" "$DEST/greeter/shell.qml"
    [ -f "$SRC/test.toml" ] && sudo install -o root -g root -m 0644 "$SRC/test.toml" "$DEST/test.toml"

    say "Verifying"
    local failed=0
    compare config.toml       || failed=1
    compare greeter/shell.qml || failed=1
    if ! sudo -u greeter test -r "$DEST/greeter/shell.qml"; then
        bad "the greeter user cannot read shell.qml"
        failed=1
    else
        ok "readable by the greeter user"
    fi
    [ "$failed" -eq 0 ] || { bad "deploy is not clean — not restarting greetd"; exit 1; }

    say "Restarting greetd"
    sudo systemctl restart greetd
    sleep 1
    if systemctl is-active --quiet greetd; then
        ok "greetd is running"
    else
        bad "greetd did not come back"
        systemctl status greetd --no-pager | tail -5
        exit 1
    fi

    printf '\n%sNow: Ctrl+Alt+F1, log in, then come back and run:%s\n' "$YELLOW" "$RESET"
    printf '  make greeter-logs\n\n'
}

cmd_logs() {
    say "greetd's view (session opened/closed = how long it lived)"
    journalctl -b --no-pager 2>/dev/null \
        | grep -E "greetd.*(session (opened|closed) for user|error|AUTH_ERR)" \
        | grep -v "user greeter" | tail -10 || note "(nothing)"
    note "opened and closed in the same second: the command exited at once."
    note "opened with no close: still running -- loginctl list-sessions,"
    note "then /proc/<pid>/cmdline of the leader's child says what it is."

    printf '\n'; say "Hyprland's own log (newest instance)"
    local log
    log=$(ls -t /run/user/"$(id -u)"/hypr/*/hyprland.log 2>/dev/null | head -1)
    if [ -n "$log" ]; then note "$log"; grep -iE "err|crit|fail" "$log" | tail -10 || note "(no errors)"
    else note "(none this boot -- Hyprland never started)"; fi

    printf '\n'; say "Session output (journal, via systemd-cat)"
    journalctl -t greetd-session -b --no-pager 2>/dev/null | tail -15 || true
    note "Errors from the shell greetd wraps the command in -- 'exec: foo: not"
    note "found' -- come before this and only ever show on tty1."
}

cmd_status() {
    say "Deployed at $DEST"
    note "$(grep -E '^command' "$DEST/config.toml" 2>/dev/null || echo '(no config.toml)')"
    compare config.toml       || true
    compare greeter/shell.qml || true
    printf '\n'; say "greetd"
    note "$(systemctl is-active greetd) / $(systemctl is-enabled greetd 2>/dev/null)"
    note "display-manager -> $(systemctl show -p Id --value display-manager 2>/dev/null)"
}

case "${1:-deploy}" in
    deploy) cmd_deploy ;;
    logs)   cmd_logs ;;
    status) cmd_status ;;
    *)      printf 'usage: %s [deploy|logs|status]\n' "$(basename "$0")"; exit 2 ;;
esac

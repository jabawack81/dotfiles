#!/bin/bash
# Verify quickshell still loads after a Qt6 upgrade, and shout if it doesn't.
#
# Run from a pacman PostTransaction hook (50-quickshell-qt6.hook). quickshell-git
# links Qt private API, so a qt6 bump can leave it unable to resolve symbols.
# When that happens the bar launcher silently falls back to waybar, which makes
# the cause easy to miss hours or days later.
#
# Exits 0 always — a broken quickshell must never fail the pacman transaction.

set -u

BIN=$(command -v quickshell 2>/dev/null || command -v qs 2>/dev/null) || exit 0
[[ -n "$BIN" ]] || exit 0

MARKER=/var/lib/quickshell-qt6-broken

if err=$("$BIN" --version 2>&1); then
    rm -f "$MARKER" 2>/dev/null
    exit 0
fi

# Only the ABI case is actionable here; anything else is a different bug.
if [[ "$err" != *"symbol lookup error"* ]]; then
    exit 0
fi

mkdir -p "$(dirname "$MARKER")" 2>/dev/null
printf '%s\n' "$err" > "$MARKER" 2>/dev/null

cat >&2 <<BANNER

  ####################################################################
  ##  quickshell is BROKEN by this Qt6 upgrade                      ##
  ####################################################################

  $err

  It links Qt private API, so the ABI moved under it. Rebuild:

      yay -S --rebuild quickshell-git

  Until then the status bar falls back to waybar. Note that rebuilding
  a -git package also pulls the latest upstream source, so expect some
  QML churn in ~/.config/quickshell.

BANNER

exit 0

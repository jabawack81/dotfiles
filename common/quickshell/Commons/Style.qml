pragma Singleton
import QtQuick
import Quickshell.Io

// Structural style tokens: typography scale, spacing scale, bar dimensions,
// and cyberpunk decorations. Corner rounding and edge gaps are read from
// Hyprland (`hyprctl getoption`) on startup so the shell visually matches
// the window manager without duplicating the values here.
QtObject {
    id: root

    // ── Hyprland-synced (rounding + gaps) ─────────────────────────────
    // cornerRadius mirrors decoration:rounding. gapsOut is half of
    // general:gaps_out — the full value is too cavernous as a panel-to-edge
    // distance.
    property int cornerRadius: 0
    property int gapsOut: 5

    Component.onCompleted: hyprSync.running = true

    property Process _hyprSync: Process {
        id: hyprSync
        command: ["bash", "-c",
            "echo $(hyprctl getoption decoration:rounding -j | jq -r '.int') " +
            "$(hyprctl getoption general:gaps_out -j | jq -r '.custom // .int' | awk '{print $1}')"]
        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.trim().split(/\s+/);
                const rounding = parseInt(parts[0]);
                const gaps = parseInt(parts[1]);
                if (isFinite(rounding)) root.cornerRadius = rounding;
                if (isFinite(gaps)) root.gapsOut = Math.round(gaps / 2);
            }
        }
    }

    // ── Typography ────────────────────────────────────────────────────
    readonly property QtObject font: QtObject {
        readonly property string family: "JetBrainsMono Nerd Font"
        readonly property int base:  13
        readonly property int small: 11
        readonly property int large: 15
        readonly property int big:   28   // dashboard clock
    }

    // ── Spacing scale ─────────────────────────────────────────────────
    readonly property QtObject spacing: QtObject {
        readonly property int xs: 2
        readonly property int sm: 4
        readonly property int md: 8
        readonly property int lg: 12
        readonly property int xl: 16
    }

    // ── Bar dimensions ────────────────────────────────────────────────
    readonly property int barHeight: 30
    readonly property int barBorderWidth: 1
    readonly property int modulePadding: 10

    // ── Cyberpunk decorations ─────────────────────────────────────────
    readonly property string bracketL: "[ "
    readonly property string bracketR: " ]"
    readonly property string separator: " · "

    // Helper: scale a base pixel value by the spacing feel (kept simple).
    function space(px) { return Math.round(px); }
}

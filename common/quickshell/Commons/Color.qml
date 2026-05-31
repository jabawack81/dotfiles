pragma Singleton
import QtQuick

// Cyberpunk palette + per-surface roles. Foundational colors are the neon
// tokens used everywhere; surface objects group the colors a given UI
// surface needs (bar, popups, notifications, menu) so components reference
// intent ("popups.border") rather than a raw hex.
QtObject {
    id: root

    // ── Foundational palette ──────────────────────────────────────────
    readonly property color foreground: "#fdf6e3"  // warm cream text
    readonly property color background: "#000000"   // terminal black
    readonly property color accent:     "#33ccff"   // primary cyan
    readonly property color accentDim:  "#1a6680"   // dim cyan
    readonly property color secondary:  "#00ff99"   // neon green
    readonly property color highlight:  "#ff00cc"   // magenta (hover)
    readonly property color warning:    "#ffcc00"   // amber
    readonly property color urgent:     "#ff0040"   // red (critical)
    readonly property color textDim:    "#586e75"   // muted text

    // ── Surface backgrounds ───────────────────────────────────────────
    readonly property color surface:        "#0a0a0a"  // panels/popups
    readonly property color surfaceInactive: "#111111" // inactive rows

    // Elevated surfaces (floating islands, popup cards, omni) — slightly
    // blue-tinted darks, a touch lighter than the flat `surface`.
    readonly property color surfaceRaised:  "#0b1016"  // island / card body
    readonly property color surfaceDeep:    "#070b0f"  // gradient end / footers

    // Heat-gradient mid step (75–85°C), between warning (amber) and urgent (red).
    readonly property color heat:           "#ff8800"

    // ── Omni / quick-panel internal shades ────────────────────────────
    readonly property QtObject omni: QtObject {
        readonly property color rowSelected:  "#16334a"  // selected result row
        readonly property color chipSelected: "#0e2a1f"  // selected icon chip (green tint)
        readonly property color chip:         "#101820"  // idle icon chip
        readonly property color chipBorder:   "#1d3340"  // idle icon chip border
        readonly property color divider:      "#13202a"  // vertical rule
        readonly property color tileBorder:   "#1a2c38"  // quick-stat tile border
    }

    // ── Per-surface roles ─────────────────────────────────────────────
    readonly property QtObject bar: QtObject {
        readonly property color background: root.background
        readonly property color text: root.foreground
        readonly property color border: root.accent
    }
    readonly property QtObject popups: QtObject {
        readonly property color background: root.surface
        readonly property color text: root.foreground
        readonly property color border: root.accent
        readonly property color selected: root.surfaceInactive
    }
    readonly property QtObject notifications: QtObject {
        readonly property color background: root.surface
        readonly property color text: root.foreground
        readonly property color normal: root.accent
        readonly property color low: root.accentDim
        readonly property color critical: root.urgent
    }
}

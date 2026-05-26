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

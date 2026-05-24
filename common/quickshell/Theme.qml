// Cyberpunk tech-terminal theme — colors, fonts, sizes.
// Singleton so any module can import and reference Theme.bg, Theme.accent, etc.
pragma Singleton
import QtQuick

QtObject {
    // === Colors ===
    // Pure black background like a terminal, neon accents.
    readonly property color bg:           "#000000"
    readonly property color bgPanel:      "#0a0a0a"
    readonly property color bgInactive:   "#111111"

    // Neon palette — bright on black
    readonly property color accent:       "#33ccff"  // primary cyan (matches hyprland border)
    readonly property color accentDim:    "#1a6680"  // dim version for inactive
    readonly property color secondary:    "#00ff99"  // neon green (matches hyprland border 2)
    readonly property color highlight:    "#ff00cc"  // magenta for emphasis
    readonly property color warning:      "#ffcc00"  // amber for warnings
    readonly property color critical:     "#ff0040"  // red for critical

    // Text
    readonly property color text:         "#fdf6e3"  // warm cream (matches waybar)
    readonly property color textDim:      "#586e75"  // dim text (matches waybar)
    readonly property color textBracket:  "#33ccff"  // bracket decorations

    // === Typography ===
    readonly property string fontFamily:  "JetBrainsMono Nerd Font"
    readonly property int    fontSize:    13
    readonly property int    fontSizeSmall: 11

    // === Sizes ===
    readonly property int barHeight:      30
    readonly property int modulePadding:  10
    readonly property int moduleSpacing:  4
    readonly property int barBorderWidth: 1

    // === Decorations ===
    // Bracket characters used to wrap module text
    readonly property string bracketL:    "[ "
    readonly property string bracketR:    " ]"
    readonly property string separator:   " · "
}

// 4-state caffeine/power module: NORM → CAFE → REMOTE → HIBR
// Reads state from ~/.cache/caffeine-state (written by caffeine-toggle.sh).
// Left-click cycles, right-click resets to normal. Renders as a BarPill.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarPill {
    id: root

    property string state: "normal"

    content: {
        switch (state) {
            case "caffeine":  return "CAFE";
            case "remote":    return "REMOTE";
            case "hibernate": return "HIBR";
            default:          return "NORM";
        }
    }
    baseColor: {
        switch (state) {
            case "caffeine":  return Color.accent;     // cyan
            case "remote":    return Color.secondary;  // green
            case "hibernate": return Color.warning;    // amber
            default:          return Color.textDim;
        }
    }

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
        const arg = (mouse.button === Qt.RightButton) ? "reset" : "";
        toggleProc.command = ["bash", Quickshell.env("HOME") + "/.config/waybar_common/caffeine-toggle.sh", arg];
        toggleProc.running = true;
    }

    Process { id: toggleProc }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: stateFile.reload()
    }

    FileView {
        id: stateFile
        path: Quickshell.env("HOME") + "/.cache/caffeine-state"
        blockLoading: true
        onLoaded: root.state = stateFile.text().trim() || "normal"
    }

    // Hover tooltip explaining what each state does, current one highlighted.
    ToolTip {
        anchorItem: root
        show: root.containsMouse
        contentWidth: 300
        contentHeight: tipCol.implicitHeight + Style.spacing.md * 2

        Column {
            id: tipCol
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 4

            Repeater {
                model: [
                    { key: "normal",    label: "NORM",   desc: "5m screen · 10m lock · 30m suspend" },
                    { key: "caffeine",  label: "CAFE",   desc: "stay awake — no idle at all" },
                    { key: "remote",    label: "REMOTE", desc: "90s lock + screens off, no suspend" },
                    { key: "hibernate", label: "HIBR",   desc: "90s lock + screens off, 5m hibernate" },
                ]
                delegate: Row {
                    required property var modelData
                    property bool current: modelData.key === root.state
                    spacing: 8
                    Text {
                        width: 56
                        text: (parent.current ? "▶ " : "  ") + modelData.label
                        color: parent.current ? Color.accent : Color.textDim
                        font.family: Style.font.family
                        font.pixelSize: Style.font.small
                        font.bold: parent.current
                    }
                    Text {
                        text: modelData.desc
                        color: parent.current ? Color.foreground : Color.textDim
                        font.family: Style.font.family
                        font.pixelSize: Style.font.small
                    }
                }
            }

            Item { width: 1; height: 2 }

            Text {
                text: "L-click: cycle · R-click: reset"
                color: Color.accentDim
                font.family: Style.font.family
                font.pixelSize: Style.font.small
            }
        }
    }
}

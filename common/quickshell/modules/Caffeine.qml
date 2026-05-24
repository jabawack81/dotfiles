// 4-state caffeine/power module: NORM → CAFE → REMOTE → HIBR
// Reads state from ~/.cache/caffeine-state (written by caffeine-toggle.sh).
// Left-click cycles, right-click resets to normal.
import QtQuick
import Quickshell
import Quickshell.Io
import "../"

MouseArea {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    property string state: "normal"

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

    function stateLabel() {
        switch (root.state) {
            case "caffeine":  return "CAFE";
            case "remote":    return "REMOTE";
            case "hibernate": return "HIBR";
            default:          return "NORM";
        }
    }

    function stateColor() {
        switch (root.state) {
            case "caffeine":  return Theme.accent;       // cyan
            case "remote":    return Theme.secondary;    // green
            case "hibernate": return Theme.warning;      // amber
            default:          return Theme.textDim;
        }
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            text: Theme.bracketL
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
        Text {
            text: root.stateLabel()
            color: root.containsMouse ? Theme.highlight : root.stateColor()
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            text: Theme.bracketR
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}

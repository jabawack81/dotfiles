// 4-state caffeine/power module: NORM → CAFE → REMOTE → HIBR
// Reads state from ~/.cache/caffeine-state (written by caffeine-toggle.sh).
// Left-click cycles, right-click resets to normal.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

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
            case "caffeine":  return Color.accent;       // cyan
            case "remote":    return Color.secondary;    // green
            case "hibernate": return Color.warning;      // amber
            default:          return Color.textDim;
        }
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            text: Style.bracketL
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.base
        }
        Text {
            text: root.stateLabel()
            color: root.containsMouse ? Color.highlight : root.stateColor()
            font.family: Style.font.family
            font.pixelSize: Style.font.base
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            text: Style.bracketR
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.base
        }
    }
}

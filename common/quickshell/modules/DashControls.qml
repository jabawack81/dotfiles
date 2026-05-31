// Dashboard quick controls: caffeine/wifi/bluetooth toggle chips + volume slider.
// Toggles shell out to the same tools the bar modules use. Bluetooth chip only
// shows when an adapter exists; brightness handled by the OSD, volume here.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Commons

Column {
    id: root
    spacing: 10
    width: parent.width

    // Bound to the dashboard popup's visibility by the parent — only poll
    // toggle states while the dashboard is actually open.
    property bool active: true

    property bool wifiOn: false
    property bool btPresent: false
    property bool btOn: false
    property string caffeineState: "normal"

    Process { id: actionProc }

    // Poll toggle states while the dashboard is open
    Timer {
        interval: 3000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            wifiProc.running = true;
            btProc.running = true;
            caffFile.reload();
        }
    }

    Process {
        id: wifiProc
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser { onRead: function(l) { root.wifiOn = l.trim() === "enabled"; } }
    }
    Process {
        id: btProc
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo on; bluetoothctl show 2>/dev/null | grep -q 'Controller' && echo present"]
        // Reset before each run so a powered-off / removed adapter clears the
        // flags — the onRead handlers only ever set them true.
        onRunningChanged: if (running) { root.btPresent = false; root.btOn = false; }
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(l) {
                const s = l.trim();
                if (s === "present") root.btPresent = true;
                if (s === "on") root.btOn = true;
            }
        }
    }
    FileView {
        id: caffFile
        path: (Quickshell.env("XDG_RUNTIME_DIR") || (Quickshell.env("HOME") + "/.cache")) + "/caffeine-state"
        blockLoading: true
        onLoaded: root.caffeineState = caffFile.text().trim() || "normal"
    }

    // === Toggle chips ===
    Row {
        spacing: 8

        // Caffeine chip — click cycles state
        Rectangle {
            width: caffText.implicitWidth + 20
            height: 26
            color: caffArea.containsMouse ? Color.surfaceInactive : Color.background
            border.width: 1
            border.color: root.caffeineState !== "normal" ? Color.accent : Color.accentDim

            Text {
                id: caffText
                anchors.centerIn: parent
                text: {
                    switch (root.caffeineState) {
                        case "caffeine":  return "☕ CAFE";
                        case "remote":    return "☕ REMOTE";
                        case "hibernate": return "☕ HIBR";
                        default:          return "☕ NORM";
                    }
                }
                color: root.caffeineState !== "normal" ? Color.accent : Color.textDim
                font.family: Style.font.family
                font.pixelSize: Style.font.small
            }
            MouseArea {
                id: caffArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    actionProc.command = ["bash", Quickshell.env("HOME") + "/.config/waybar_common/caffeine-toggle.sh", ""];
                    actionProc.running = true;
                }
            }
        }

        // Wifi chip
        Rectangle {
            width: wifiText.implicitWidth + 20
            height: 26
            color: wifiArea.containsMouse ? Color.surfaceInactive : Color.background
            border.width: 1
            border.color: root.wifiOn ? Color.secondary : Color.accentDim

            Text {
                id: wifiText
                anchors.centerIn: parent
                text: root.wifiOn ? "󰖩 WIFI" : "󰖪 WIFI"
                color: root.wifiOn ? Color.secondary : Color.textDim
                font.family: Style.font.family
                font.pixelSize: Style.font.small
            }
            MouseArea {
                id: wifiArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    actionProc.command = ["nmcli", "radio", "wifi", root.wifiOn ? "off" : "on"];
                    actionProc.running = true;
                }
            }
        }

        // Bluetooth chip (only if adapter present)
        Rectangle {
            visible: root.btPresent
            width: btText.implicitWidth + 20
            height: 26
            color: btArea.containsMouse ? Color.surfaceInactive : Color.background
            border.width: 1
            border.color: root.btOn ? Color.accent : Color.accentDim

            Text {
                id: btText
                anchors.centerIn: parent
                text: root.btOn ? "󰂯 BT" : "󰂲 BT"
                color: root.btOn ? Color.accent : Color.textDim
                font.family: Style.font.family
                font.pixelSize: Style.font.small
            }
            MouseArea {
                id: btArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    actionProc.command = ["bluetoothctl", "power", root.btOn ? "off" : "on"];
                    actionProc.running = true;
                }
            }
        }
    }

    // === Volume slider ===
    property var sink: Pipewire.defaultAudioSink
    property int volume: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    Column {
        width: parent.width
        spacing: 4

        Text {
            text: "VOL " + root.volume + "%"
            color: Color.textDim
            font.family: Style.font.family
            font.pixelSize: Style.font.small
        }

        // Track + fill + draggable handle
        Rectangle {
            id: track
            width: parent.width
            height: 8
            color: Color.surfaceInactive
            border.width: 1
            border.color: Color.accentDim

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * (root.volume / 100)
                color: Color.accent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: function(mouse) { setVol(mouse.x); }
                onPositionChanged: function(mouse) { if (pressed) setVol(mouse.x); }
                function setVol(x) {
                    if (!root.sink || !root.sink.audio) return;
                    const v = Math.max(0, Math.min(1, x / track.width));
                    root.sink.audio.volume = v;
                }
            }
        }
    }
}

// Quick-stats dashboard for the omni menu (empty-query view).
// Glyph-forward "quick panel" tiles à la bjarneo/quickshell: big nerd-font
// icon + LABEL + value sub-line, tone-coloured by state. Live data from the
// shared SystemUsage service, Pipewire, nmcli and bluetoothctl. Audio tile
// toggles mute; power tile opens the system actions.
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import qs.Commons

Item {
    id: root
    property int cols: 4
    property int gap: 10
    property int tileW: Math.floor((width - gap * (cols - 1)) / cols)

    // ── live state ────────────────────────────────────────────────────
    property string timeStr: ""
    property string dateStr: ""
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            const d = new Date();
            root.timeStr = Qt.formatDateTime(d, "HH:mm");
            root.dateStr = Qt.formatDateTime(d, "ddd dd MMM");
        }
    }

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
    property var sink: Pipewire.defaultAudioSink
    property bool audioMuted: sink && sink.audio ? sink.audio.muted : false
    property int volume: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0

    property string netKind: "none"   // wifi | eth | none
    property string netSub: "—"
    property bool btPresent: false
    property bool btOn: false
    property int btCount: 0

    Process { id: actionProc }
    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { netProc.running = true; btProc.running = true; }
    }
    Process {
        id: netProc
        command: ["bash", "-c", `
            line=$(nmcli -t -f TYPE,CONNECTION,STATE device status 2>/dev/null | \
                   awk -F: '$3=="connected" && ($1=="wifi"||$1=="ethernet"){print $1 ":" $2; exit}')
            sig=$(nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1=="*"{print $2; exit}')
            echo "$line|$sig"
        `]
        stdout: SplitParser {
            onRead: function(l) {
                const [dev, sig] = l.trim().split("|");
                if (!dev) { root.netKind = "none"; root.netSub = "OFFLINE"; return; }
                const [type, conn] = dev.split(":");
                if (type === "wifi") { root.netKind = "wifi"; root.netSub = conn + (sig ? " " + sig + "%" : ""); }
                else { root.netKind = "eth"; root.netSub = "CONNECTED"; }
            }
        }
    }
    Process {
        id: btProc
        command: ["bash", "-c", `
            bluetoothctl show 2>/dev/null | grep -q 'Controller' && echo present
            bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo on
            echo "count:$(bluetoothctl devices Connected 2>/dev/null | grep -c Device)"
        `]
        // Reset before each run — onRead only ever sets these true, so without
        // this a powered-off / removed adapter would stay showing ON.
        onRunningChanged: if (running) { root.btPresent = false; root.btOn = false; root.btCount = 0; }
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(l) {
                const s = l.trim();
                if (s === "present") root.btPresent = true;
                else if (s === "on") root.btOn = true;
                else if (s.startsWith("count:")) root.btCount = parseInt(s.slice(6)) || 0;
            }
        }
    }

    // ── helpers ───────────────────────────────────────────────────────
    function heat(c) {
        if (c >= 85) return Color.urgent;
        if (c >= 75) return "#ff8800";
        if (c >= 60) return Color.warning;
        return Color.secondary;
    }
    function load(pct) {
        if (pct >= 90) return Color.urgent;
        if (pct >= 75) return Color.warning;
        return Color.foreground;
    }

    // ── tile ──────────────────────────────────────────────────────────
    component Tile: Rectangle {
        property string glyph: ""
        property string label: ""
        property string sub: ""
        property color tone: Color.foreground
        signal activated()

        width: root.tileW
        height: 84
        radius: 12
        color: tileMouse.containsMouse ? Qt.rgba(0.2, 0.8, 1, 0.06) : Qt.rgba(1, 1, 1, 0.02)
        border.color: tileMouse.containsMouse ? Color.accent : "#1a2c38"
        border.width: 1
        Behavior on color { ColorAnimation { duration: 80 } }
        Behavior on border.color { ColorAnimation { duration: 80 } }

        Column {
            anchors.fill: parent
            anchors.margins: 11
            spacing: 3
            Text {
                text: parent.parent.glyph
                color: parent.parent.tone
                font.family: Style.font.family; font.pixelSize: 22
            }
            Text {
                text: parent.parent.label
                color: Color.textDim
                font.family: Style.font.family; font.pixelSize: 10; font.bold: true
            }
            Text {
                text: parent.parent.sub
                color: Color.foreground
                font.family: Style.font.family; font.pixelSize: 13
                elide: Text.ElideRight; width: parent.width
            }
        }

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.activated()
        }
    }

    Grid {
        anchors.centerIn: parent
        columns: root.cols
        columnSpacing: root.gap
        rowSpacing: root.gap

        Tile { glyph: "󰻠"; label: "CPU";    tone: root.load(SystemUsage.cpuPercent);  sub: SystemUsage.cpuPercent + "%" }
        Tile { glyph: "󰾆"; label: "MEMORY"; tone: root.load(SystemUsage.memPercent);  sub: SystemUsage.memUsedGib.toFixed(1) + "/" + SystemUsage.memTotalGib.toFixed(0) + "G" }
        Tile { glyph: "󰋊"; label: "DISK /";  tone: root.load(SystemUsage.diskPercent); sub: SystemUsage.diskPercent + "%" }
        Tile { glyph: "󰔏"; label: "CPU TEMP"; tone: root.heat(SystemUsage.cpuTemp);    sub: SystemUsage.cpuTemp + "°C" }

        Tile {
            glyph: "󰢮"; label: "GPU TEMP"; tone: root.heat(SystemUsage.gpuTemp)
            sub: SystemUsage.gpuPresent ? SystemUsage.gpuTemp + "°C" : "—"
        }
        Tile {
            glyph: root.audioMuted ? "󰝟" : "󰕾"; label: "AUDIO"
            tone: root.audioMuted ? Color.urgent : Color.accent
            sub: root.audioMuted ? "MUTED" : root.volume + "%"
            onActivated: if (root.sink && root.sink.audio) root.sink.audio.muted = !root.sink.audio.muted
        }
        Tile {
            glyph: root.netKind === "wifi" ? "󰖩" : (root.netKind === "eth" ? "󰈁" : "󰖪")
            label: root.netKind === "wifi" ? "WI-FI" : (root.netKind === "eth" ? "ETHERNET" : "OFFLINE")
            tone: root.netKind === "none" ? Color.textDim : Color.accent
            sub: root.netSub
        }
        Tile {
            visible: root.btPresent
            glyph: root.btOn ? "󰂯" : "󰂲"; label: "BLUETOOTH"
            tone: root.btOn ? Color.accent : Color.textDim
            sub: !root.btOn ? "OFF" : (root.btCount > 0 ? root.btCount + " CONN" : "ON")
        }

        Tile { glyph: "󰅐"; label: "UPTIME";  tone: Color.secondary; sub: SystemUsage.uptime }
        Tile { glyph: "󰃭"; label: "DATE";    tone: Color.foreground; sub: root.dateStr }
        Tile { glyph: "󰥔"; label: "TIME";    tone: Color.foreground; sub: root.timeStr }
        Tile {
            glyph: "󰐥"; label: "POWER"; tone: Color.urgent; sub: "LOCK · OFF"
            onActivated: { actionProc.command = ["bash", "-c", "hyprlock"]; actionProc.running = true; Globals.omniOpen = false; }
        }
    }
}

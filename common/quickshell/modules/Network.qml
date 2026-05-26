// Network indicator via nmcli. Shows ETH/WIFI/OFF + SSID for wifi.
// Polls every 5s — slower than CPU/audio because it's chattier and changes rarely.
import QtQuick
import Quickshell.Io
import qs.Commons

Row {
    id: root
    spacing: 0
    anchors.verticalCenter: parent.verticalCenter

    property string label: "..."
    property string state: "off"   // off | wired | wifi | limited

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    Process {
        id: netProc
        // Output: STATE\tTYPE\tCONN
        // STATE = connected|connecting|disconnected, TYPE = ethernet|wifi, CONN = name
        command: ["bash", "-c", `
            state=$(nmcli -t -f STATE general status 2>/dev/null | head -1)
            line=$(nmcli -t -f TYPE,CONNECTION,STATE device status 2>/dev/null | \
                   awk -F: '$3=="connected" && ($1=="wifi" || $1=="ethernet"){print $1 ":" $2; exit}')
            echo "$state|$line"
        `]
        stdout: SplitParser {
            onRead: function(line) {
                const [gs, dev] = line.trim().split("|");
                if (!dev) {
                    root.state = "off";
                    root.label = "OFF";
                    return;
                }
                const [type, conn] = dev.split(":");
                if (gs && gs.includes("limited")) {
                    root.state = "limited";
                    root.label = (type === "wifi" ? "WIFI " : "ETH ") + "· NO NET";
                } else if (type === "wifi") {
                    root.state = "wifi";
                    root.label = "WIFI · " + conn;
                } else {
                    root.state = "wired";
                    root.label = "ETH";
                }
            }
        }
    }

    function netColor() {
        if (root.state === "off")     return Color.urgent;
        if (root.state === "limited") return Color.warning;
        return Color.foreground;
    }

    Text {
        text: Style.bracketL
        color: Color.accent
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: root.label
        color: root.netColor()
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: Style.bracketR
        color: Color.accent
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        anchors.verticalCenter: parent.verticalCenter
    }
}

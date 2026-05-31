// Network indicator via nmcli. Shows ETH/WIFI/OFF + SSID for wifi.
// Polls every 5s — chattier and changes rarely. Renders as a BarPill.
import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarPill {
    id: root
    hoverHighlight: false

    property string state: "off"   // off | wired | wifi | limited

    content: "..."
    baseColor: {
        if (state === "off")     return Color.urgent;
        if (state === "limited") return Color.warning;
        return Color.foreground;
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    Process {
        id: netProc
        // Output: STATE|TYPE:CONN
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
                    root.content = "OFF";
                    return;
                }
                const [type, rawConn] = dev.split(":");
                // Cap the SSID so a long network name can't stretch the island
                // over the centre clock.
                const conn = rawConn && rawConn.length > 20 ? rawConn.slice(0, 19) + "…" : rawConn;
                if (gs && gs.includes("limited")) {
                    root.state = "limited";
                    root.content = (type === "wifi" ? "WIFI " : "ETH ") + "· NO NET";
                } else if (type === "wifi") {
                    root.state = "wifi";
                    root.content = "WIFI · " + conn;
                } else {
                    root.state = "wired";
                    root.content = "ETH";
                }
            }
        }
    }
}

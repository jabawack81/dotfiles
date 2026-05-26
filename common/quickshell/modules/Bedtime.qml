// Bedtime indicator. Reads severity/class/message from time-status.sh.
// Color escalates with severity. Hidden during normal not-bedtime hours
// to keep the bar quiet — only appears when there's something to flag.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Row {
    id: root
    spacing: 0
    anchors.verticalCenter: parent.verticalCenter
    visible: label !== ""

    property string label: ""
    property string severityClass: "good"

    Timer {
        interval: 30000  // 30s — bedtime state changes by the hour, no rush
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }

    Process {
        id: statusProc
        // Reuse the central time-status.sh in "status" mode (key=value output).
        command: ["bash", Quickshell.env("HOME") + "/.config/bedtime/time-status.sh", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text;
                const kv = {};
                for (const line of out.split("\n")) {
                    const idx = line.indexOf("=");
                    if (idx > 0) kv[line.slice(0, idx)] = line.slice(idx + 1);
                }
                root.severityClass = kv.class || "good";

                // Only show during work, lunch, weekend (informational) or bedtime severity > 0
                const sev = parseInt(kv.severity);
                if (sev === 0) { root.label = ""; return; }

                switch (kv.class) {
                    case "work":     root.label = "WORK"; break;
                    case "lunch":    root.label = "LUNCH"; break;
                    case "weekend":  root.label = "WKND"; break;
                    case "info":     root.label = "WIND DOWN"; break;
                    case "warning":  root.label = "GO TO BED"; break;
                    case "critical": root.label = "SLEEP NOW"; break;
                    default:         root.label = "";
                }
            }
        }
    }

    function bedtimeColor() {
        switch (root.severityClass) {
            case "work":     return Color.accent;
            case "lunch":    return Color.warning;
            case "weekend":  return Color.highlight;
            case "info":     return Color.warning;
            case "warning":  return "#cb4b16";   // orange
            case "critical": return Color.urgent;
            default:         return Color.foreground;
        }
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
        color: root.bedtimeColor()
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        font.bold: root.severityClass === "critical" || root.severityClass === "warning"
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

// Bedtime indicator. Reads severity/class from time-status.sh. Color escalates
// with severity; hidden during normal not-bedtime hours. Renders as a BarPill.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarPill {
    id: root
    hoverHighlight: false
    visible: content !== ""

    property string severityClass: "good"

    content: ""
    bold: severityClass === "critical" || severityClass === "warning"
    baseColor: {
        switch (severityClass) {
            case "work":     return Color.accent;
            case "lunch":    return Color.warning;
            case "weekend":  return Color.highlight;
            case "info":     return Color.warning;
            case "warning":  return "#cb4b16";   // orange
            case "critical": return Color.urgent;
            default:         return Color.foreground;
        }
    }

    Timer {
        interval: 30000  // 30s — bedtime state changes by the hour, no rush
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }

    Process {
        id: statusProc
        command: ["bash", Quickshell.env("HOME") + "/.config/bedtime/time-status.sh", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const kv = {};
                for (const line of this.text.split("\n")) {
                    const idx = line.indexOf("=");
                    if (idx > 0) kv[line.slice(0, idx)] = line.slice(idx + 1);
                }
                root.severityClass = kv.class || "good";

                if (parseInt(kv.severity) === 0) { root.content = ""; return; }

                switch (kv.class) {
                    case "work":     root.content = "WORK"; break;
                    case "lunch":    root.content = "LUNCH"; break;
                    case "weekend":  root.content = "WKND"; break;
                    case "info":     root.content = "WIND DOWN"; break;
                    case "warning":  root.content = "GO TO BED"; break;
                    case "critical": root.content = "SLEEP NOW"; break;
                    default:         root.content = "";
                }
            }
        }
    }
}

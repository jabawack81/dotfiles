// CPU and memory readout in terminal-bar style: CPU ▓▓▓░░░ 42% MEM ▓▓░░░░ 8.2G
// Reads from the shared SystemUsage service (no own /proc polling).
import QtQuick
import qs.Commons
import qs.Ui

Row {
    id: root
    spacing: 12
    anchors.verticalCenter: parent.verticalCenter

    function bar(pct) {
        const w = 8;
        const filled = Math.round(pct / 100 * w);
        return "▓".repeat(filled) + "░".repeat(w - filled);
    }

    function statColor(pct) {
        if (pct >= 90) return Color.urgent;
        if (pct >= 75) return Color.warning;
        return Color.foreground;
    }

    BarText { text: "CPU"; color: Color.textDim; anchors.verticalCenter: parent.verticalCenter }
    BarText {
        text: root.bar(SystemUsage.cpuPercent)
        color: root.statColor(SystemUsage.cpuPercent)
        anchors.verticalCenter: parent.verticalCenter
    }
    BarText {
        text: String(SystemUsage.cpuPercent).padStart(2, "0") + "%"
        color: root.statColor(SystemUsage.cpuPercent)
        anchors.verticalCenter: parent.verticalCenter
    }

    BarText { text: "│"; color: Color.accentDim; anchors.verticalCenter: parent.verticalCenter }

    BarText { text: "MEM"; color: Color.textDim; anchors.verticalCenter: parent.verticalCenter }
    BarText {
        text: root.bar(SystemUsage.memPercent)
        color: root.statColor(SystemUsage.memPercent)
        anchors.verticalCenter: parent.verticalCenter
    }
    BarText {
        text: SystemUsage.memUsedGib.toFixed(1) + "G"
        color: root.statColor(SystemUsage.memPercent)
        anchors.verticalCenter: parent.verticalCenter
    }
}

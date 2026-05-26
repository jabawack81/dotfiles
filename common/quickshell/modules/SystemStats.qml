// CPU and memory readout in terminal-bar style: CPU ▓▓▓░░░ 42% MEM ▓▓░░░░ 8.2G
// Polls /proc/stat and /proc/meminfo every 2s.
import QtQuick
import Quickshell.Io
import qs.Commons

Row {
    id: root
    spacing: 12
    anchors.verticalCenter: parent.verticalCenter

    property int cpuPercent: 0
    property real memUsedGib: 0
    property real memTotalGib: 0
    property int memPercent: 0

    // Track previous CPU stats for delta calculation
    property var prevCpu: ({ total: 0, idle: 0 })

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuReader.reload();
            memReader.reload();
        }
    }

    FileView {
        id: cpuReader
        path: "/proc/stat"
        blockLoading: true
        onLoaded: {
            const firstLine = cpuReader.text().split("\n")[0];
            // "cpu  user nice system idle iowait irq softirq steal ..."
            const parts = firstLine.split(/\s+/).slice(1).map(Number);
            const idle = parts[3] + (parts[4] || 0);
            const total = parts.reduce((a, b) => a + b, 0);
            const dIdle = idle - root.prevCpu.idle;
            const dTotal = total - root.prevCpu.total;
            if (dTotal > 0 && root.prevCpu.total > 0) {
                root.cpuPercent = Math.round(100 * (1 - dIdle / dTotal));
            }
            root.prevCpu = { total: total, idle: idle };
        }
    }

    FileView {
        id: memReader
        path: "/proc/meminfo"
        blockLoading: true
        onLoaded: {
            const lines = memReader.text().split("\n");
            const get = (key) => {
                const line = lines.find(l => l.startsWith(key + ":"));
                return line ? parseInt(line.split(/\s+/)[1]) : 0;
            };
            const totalKb = get("MemTotal");
            const availKb = get("MemAvailable");
            const usedKb = totalKb - availKb;
            root.memTotalGib = totalKb / 1024 / 1024;
            root.memUsedGib = usedKb / 1024 / 1024;
            root.memPercent = totalKb > 0 ? Math.round(100 * usedKb / totalKb) : 0;
        }
    }

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

    Text {
        text: "CPU"
        color: Color.textDim
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: root.bar(root.cpuPercent)
        color: root.statColor(root.cpuPercent)
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: String(root.cpuPercent).padStart(2, "0") + "%"
        color: root.statColor(root.cpuPercent)
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: "│"
        color: Color.accentDim
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: "MEM"
        color: Color.textDim
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: root.bar(root.memPercent)
        color: root.statColor(root.memPercent)
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: root.memUsedGib.toFixed(1) + "G"
        color: root.statColor(root.memPercent)
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        anchors.verticalCenter: parent.verticalCenter
    }
}

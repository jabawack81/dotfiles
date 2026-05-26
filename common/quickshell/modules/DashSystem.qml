// System summary for the dashboard: CPU%, MEM, disk, temps, uptime.
// Polls every 3s while visible. Reuses /proc readers like SystemStats.
import QtQuick
import Quickshell.Io
import qs.Commons

Column {
    id: root
    spacing: 6

    property int cpuPercent: 0
    property real memUsedGib: 0
    property real memTotalGib: 0
    property int memPercent: 0
    property int diskPercent: 0
    property string uptime: ""
    property var prevCpu: ({ total: 0, idle: 0 })

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuReader.reload();
            memReader.reload();
            statProc.running = true;
        }
    }

    FileView {
        id: cpuReader
        path: "/proc/stat"
        blockLoading: true
        onLoaded: {
            const parts = cpuReader.text().split("\n")[0].split(/\s+/).slice(1).map(Number);
            const idle = parts[3] + (parts[4] || 0);
            const total = parts.reduce((a, b) => a + b, 0);
            const dIdle = idle - root.prevCpu.idle;
            const dTotal = total - root.prevCpu.total;
            if (dTotal > 0 && root.prevCpu.total > 0)
                root.cpuPercent = Math.round(100 * (1 - dIdle / dTotal));
            root.prevCpu = { total: total, idle: idle };
        }
    }

    FileView {
        id: memReader
        path: "/proc/meminfo"
        blockLoading: true
        onLoaded: {
            const lines = memReader.text().split("\n");
            const get = (k) => {
                const l = lines.find(x => x.startsWith(k + ":"));
                return l ? parseInt(l.split(/\s+/)[1]) : 0;
            };
            const total = get("MemTotal");
            const avail = get("MemAvailable");
            root.memTotalGib = total / 1024 / 1024;
            root.memUsedGib = (total - avail) / 1024 / 1024;
            root.memPercent = total > 0 ? Math.round(100 * (total - avail) / total) : 0;
        }
    }

    Process {
        id: statProc
        command: ["bash", "-c",
            "df --output=pcent / | tail -1 | tr -dc '0-9'; echo; " +
            "awk '{d=int($1/86400); h=int(($1%86400)/3600); m=int(($1%3600)/60); " +
            "printf \"%dd %dh %dm\", d, h, m}' /proc/uptime"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n");
                root.diskPercent = parseInt(lines[0]) || 0;
                root.uptime = lines[1] || "";
            }
        }
    }

    function bar(pct) {
        const w = 12;
        const filled = Math.round(pct / 100 * w);
        return "▓".repeat(filled) + "░".repeat(w - filled);
    }

    Text {
        text: "CPU  " + root.bar(root.cpuPercent) + "  " + String(root.cpuPercent).padStart(2, "0") + "%"
        color: Color.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.small
    }
    Text {
        text: "MEM  " + root.bar(root.memPercent) + "  " + root.memUsedGib.toFixed(1) + "/" + root.memTotalGib.toFixed(0) + "G"
        color: Color.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.small
    }
    Text {
        text: "DISK " + root.bar(root.diskPercent) + "  " + String(root.diskPercent).padStart(2, "0") + "%"
        color: Color.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.small
    }
    Text {
        text: "UP   " + root.uptime
        color: Color.textDim
        font.family: Style.font.family
        font.pixelSize: Style.font.small
    }
}

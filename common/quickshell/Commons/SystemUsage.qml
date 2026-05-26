pragma Singleton
import QtQuick
import Quickshell.Io

// Shared system-usage readings (CPU %, memory, disk, uptime) parsed from
// /proc and df. Polls on a single timer so the bar widget and the dashboard
// summary share one source instead of each re-reading /proc.
QtObject {
    id: root

    property int cpuPercent: 0
    property real memUsedGib: 0
    property real memTotalGib: 0
    property int memPercent: 0
    property int diskPercent: 0
    property string uptime: ""
    property int cpuTemp: 0
    property int gpuTemp: 0
    property bool gpuPresent: false

    // Previous CPU counters for delta calculation.
    property var _prevCpu: ({ total: 0, idle: 0 })

    function refresh() {
        cpuReader.reload();
        memReader.reload();
        extraProc.running = true;
        tempProc.running = true;
    }

    property Timer _timer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property FileView _cpuReader: FileView {
        id: cpuReader
        path: "/proc/stat"
        blockLoading: true
        onLoaded: {
            const parts = cpuReader.text().split("\n")[0].split(/\s+/).slice(1).map(Number);
            const idle = parts[3] + (parts[4] || 0);
            const total = parts.reduce((a, b) => a + b, 0);
            const dIdle = idle - root._prevCpu.idle;
            const dTotal = total - root._prevCpu.total;
            if (dTotal > 0 && root._prevCpu.total > 0)
                root.cpuPercent = Math.round(100 * (1 - dIdle / dTotal));
            root._prevCpu = { total: total, idle: idle };
        }
    }

    property FileView _memReader: FileView {
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

    // Disk % (root) and uptime in one shell call.
    property Process _extraProc: Process {
        id: extraProc
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

    // CPU + GPU temps from hwmon (resolved by name each tick — numbering shifts).
    property Process _tempProc: Process {
        id: tempProc
        command: ["bash", "-c", `
            cpu=0; gpu=0
            for h in /sys/class/hwmon/hwmon*; do
                n=$(cat "$h/name" 2>/dev/null) || continue
                case "$n" in
                    k10temp|coretemp) [ "$cpu" = 0 ] && cpu=$(cat "$h/temp1_input" 2>/dev/null || echo 0) ;;
                    amdgpu|nvidia)    [ "$gpu" = 0 ] && gpu=$(cat "$h/temp1_input" 2>/dev/null || echo 0) ;;
                esac
            done
            echo "$cpu $gpu"
        `]
        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.trim().split(/\s+/);
                root.cpuTemp = Math.round(parseInt(parts[0]) / 1000);
                root.gpuTemp = Math.round(parseInt(parts[1]) / 1000);
                root.gpuPresent = root.gpuTemp > 0;
            }
        }
    }
}

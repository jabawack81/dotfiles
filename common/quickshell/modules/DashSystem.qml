// System summary for the dashboard: CPU%, MEM, disk, uptime.
// Reads from the shared SystemUsage service (same source as the bar widget).
import QtQuick
import qs.Commons
import qs.Ui

Column {
    id: root
    spacing: 6

    // Kept for API symmetry with the bar widget; SystemUsage polls globally
    // so there's nothing to gate here, but the parent still binds it.
    property bool active: true

    function bar(pct) {
        const w = 12;
        const filled = Math.round(pct / 100 * w);
        return "▓".repeat(filled) + "░".repeat(w - filled);
    }

    BarText {
        small: true
        text: "CPU  " + root.bar(SystemUsage.cpuPercent) + "  " + String(SystemUsage.cpuPercent).padStart(2, "0") + "%"
    }
    BarText {
        small: true
        text: "MEM  " + root.bar(SystemUsage.memPercent) + "  " + SystemUsage.memUsedGib.toFixed(1) + "/" + SystemUsage.memTotalGib.toFixed(0) + "G"
    }
    BarText {
        small: true
        text: "DISK " + root.bar(SystemUsage.diskPercent) + "  " + String(SystemUsage.diskPercent).padStart(2, "0") + "%"
    }
    BarText {
        small: true
        color: Color.textDim
        text: "UP   " + SystemUsage.uptime
    }
}

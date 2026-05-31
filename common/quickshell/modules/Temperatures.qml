// CPU + GPU temperatures from /sys/class/hwmon.
// Polls every 2s via a small shell snippet because hwmon numbering can shift
// between boots — we resolve devices by their `name` file each tick.
import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

Row {
    id: root
    spacing: 12
    anchors.verticalCenter: parent.verticalCenter

    property int cpuTemp: 0
    property int gpuTemp: 0
    property bool gpuPresent: false

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: tempProc.running = true
    }

    Process {
        id: tempProc
        // Find k10temp or coretemp for CPU; amdgpu or nvidia for GPU.
        // Print "cpu_milli gpu_milli" — missing GPU prints 0.
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

    // Heat gradient: green (cool) → amber → orange → red (critical)
    function tempColor(c) {
        if (c >= 85) return Color.urgent;     // red
        if (c >= 75) return Color.heat;       // orange
        if (c >= 60) return Color.warning;    // amber
        return Color.secondary;               // green — running cool
    }

    function isCritical(c) {
        return c >= 85;
    }

    BarText {
        text: "CPU"
        color: Color.textDim
        anchors.verticalCenter: parent.verticalCenter
    }
    BarText {
        text: String(root.cpuTemp).padStart(2, "0") + "°"
        color: root.tempColor(root.cpuTemp)
        font.bold: root.isCritical(root.cpuTemp)
        anchors.verticalCenter: parent.verticalCenter
    }

    BarText {
        visible: root.gpuPresent
        text: "│"
        color: Color.accentDim
        anchors.verticalCenter: parent.verticalCenter
    }
    BarText {
        visible: root.gpuPresent
        text: "GPU"
        color: Color.textDim
        anchors.verticalCenter: parent.verticalCenter
    }
    BarText {
        visible: root.gpuPresent
        text: String(root.gpuTemp).padStart(2, "0") + "°"
        color: root.tempColor(root.gpuTemp)
        font.bold: root.isCritical(root.gpuTemp)
        anchors.verticalCenter: parent.verticalCenter
    }
}

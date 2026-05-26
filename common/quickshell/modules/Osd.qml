// On-screen display for volume + brightness changes.
// Appears bottom-center, shows a neon level bar, auto-hides after 1.5s.
// Volume via Pipewire (all machines); brightness via /sys/class/backlight
// (laptops only — silently inactive where there's no backlight device).
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Io
import qs.Commons

Scope {
    id: scope

    // What's currently shown: "volume" | "brightness"
    property string osdType: "volume"
    property int osdValue: 0
    property bool osdMuted: false

    // Skip the very first binding evaluation so the OSD doesn't flash on launch.
    property bool volumeReady: false
    property bool brightnessReady: false

    function show(type) {
        scope.osdType = type;
        hideTimer.restart();
        osdLoader.active = true;
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: osdLoader.active = false
    }

    // === Volume tracking ===
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
        function onVolumeChanged() {
            if (!scope.volumeReady) { scope.volumeReady = true; return; }
            const a = Pipewire.defaultAudioSink.audio;
            scope.osdValue = Math.round(a.volume * 100);
            scope.osdMuted = a.muted;
            scope.show("volume");
        }
        function onMutedChanged() {
            if (!scope.volumeReady) return;
            const a = Pipewire.defaultAudioSink.audio;
            scope.osdValue = Math.round(a.volume * 100);
            scope.osdMuted = a.muted;
            scope.show("volume");
        }
    }

    // === Brightness tracking (laptops) ===
    // Discover the backlight device at startup. On desktops with no backlight
    // both paths stay empty and the FileView never attempts a read.
    property int brightMax: 0
    property string brightPath: ""
    Process {
        id: brightInit
        running: true
        command: ["bash", "-c",
            "d=$(ls -d /sys/class/backlight/*/ 2>/dev/null | head -1); " +
            "[ -n \"$d\" ] && echo \"$(cat ${d}max_brightness)|${d}brightness\""]
        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.trim().split("|");
                if (parts.length === 2) {
                    scope.brightMax = parseInt(parts[0]) || 0;
                    scope.brightPath = parts[1];
                }
            }
        }
    }

    FileView {
        id: brightFile
        path: scope.brightPath   // empty until discovered; no-op on desktops
        watchChanges: scope.brightPath !== ""
        onFileChanged: reload()
        onLoaded: {
            if (scope.brightMax <= 0) return;
            if (!scope.brightnessReady) { scope.brightnessReady = true; return; }
            const cur = parseInt(brightFile.text().trim()) || 0;
            scope.osdValue = Math.round(100 * cur / scope.brightMax);
            scope.show("brightness");
        }
    }

    // === Display (one per screen) ===
    LazyLoader {
        id: osdLoader
        active: false

        component: Variants {
            model: Quickshell.screens

            PanelWindow {
                required property var modelData
                screen: modelData

                anchors.bottom: true
                margins.bottom: 80
                implicitWidth: 320
                implicitHeight: 56
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay

                Rectangle {
                    anchors.fill: parent
                    color: Color.surface
                    border.color: Color.accent
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 40
                        spacing: 8

                        Text {
                            text: {
                                if (scope.osdType === "brightness") return "BRIGHT " + scope.osdValue + "%";
                                if (scope.osdMuted) return "VOL · MUTE";
                                return "VOL " + scope.osdValue + "%";
                            }
                            color: scope.osdMuted ? Color.urgent : Color.accent
                            font.family: Style.font.family
                            font.pixelSize: Style.font.base
                            font.bold: true
                        }

                        // Segmented neon level bar
                        Row {
                            spacing: 2
                            Repeater {
                                model: 20
                                delegate: Rectangle {
                                    required property int index
                                    width: 12
                                    height: 8
                                    property bool lit: (index + 1) * 5 <= scope.osdValue
                                    color: !lit ? Color.surfaceInactive
                                         : scope.osdMuted ? Color.urgent
                                         : (scope.osdType === "brightness" ? Color.warning : Color.accent)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

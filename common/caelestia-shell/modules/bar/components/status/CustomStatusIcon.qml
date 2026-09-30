pragma ComponentBehavior: Bound

// Local addition (not upstream caelestia) — see CHANGES-LOCAL.md.
//
// Icon-only status entry for the StatusIcons island, driven by one of the
// dotfiles status scripts. Same shape as the network and bluetooth icons
// beside it: medium filled Material Symbol in the island's colour, with
// the state carried by which icon is shown rather than by a label.
//
// The bar entries that show a value (GPU, fan) use CustomStatus instead —
// the island has no room for text.

import QtQuick
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services

MaterialIcon {
    id: root

    // Command emitting waybar JSON on stdout
    required property var cmd
    // Fallback icon, and per-class overrides for scripts whose whole state
    // lives in `class`
    required property string icon
    property var iconMap: ({})
    property int interval: 5000

    property string statusClass: ""

    animate: true
    text: root.iconMap[root.statusClass] ?? root.icon
    fontStyle: Tokens.font.icon.medium
    fill: 1

    Process {
        id: proc

        command: root.cmd
        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim();
                if (out.length === 0)
                    return;
                try {
                    root.statusClass = JSON.parse(out).class ?? "";
                } catch (e) {
                    // leave the previous state showing
                }
            }
        }
    }

    Timer {
        running: true
        triggeredOnStart: true
        interval: root.interval
        repeat: true
        onTriggered: {
            if (!proc.running)
                proc.running = true;
        }
    }
}

pragma ComponentBehavior: Bound

// Local addition (not upstream caelestia) — see CHANGES-LOCAL.md.
//
// A bar entry driven by one of the dotfiles status scripts in
// common/waybar and common/bedtime. Those scripts already emit waybar's
// JSON ({text, tooltip, class}) and are what the waybar bars use, so the
// two bars cannot disagree about the numbers they show.
//
// Only `class` and the numeric part of `text` are used here: the scripts
// put a Nerd Font glyph in `text`, which would clash with the Material
// Symbols the rest of this bar is drawn in, so the icon is given in QML
// instead and the glyph is stripped.

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    // Material Symbols icon name, e.g. "mode_fan"
    required property string icon
    // Command emitting waybar JSON on stdout
    required property var cmd
    // Optional command to run when clicked
    property var clickCmd: null
    property int interval: 5000
    // Optional per-class icon overrides, e.g. ({ remote: "lan" }). Some of
    // the scripts are icon-only and carry their whole state in `class`.
    property var iconMap: ({})

    // Parsed from the script's output
    property bool hasData: false
    property string label: ""
    property string tooltipText: ""
    property string statusClass: ""

    readonly property string currentIcon: root.iconMap[root.statusClass] ?? root.icon

    readonly property color colour: {
        switch (statusClass) {
        case "critical":
        case "disaster":
            return Colours.palette.m3error;
        case "warning":
        case "high":
            return Colours.palette.m3secondary;
        case "disabled":
        case "unknown":
            return Colours.palette.m3onSurfaceVariant;
        default:
            return Colours.palette.m3tertiary;
        }
    }

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: layout.implicitHeight + Tokens.padding.extraSmall * 2

    color: "transparent"
    visible: root.hasData

    ColumnLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Tokens.spacing.extraSmall / 2

        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            text: root.currentIcon
            color: root.colour
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: root.label
            font: Tokens.font.body.builders.small.scale(0.85).build()
            color: root.colour
            visible: root.label.length > 0
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.clickCmd !== null
        onClicked: Quickshell.execDetached(root.clickCmd)
    }

    StyledRect {
        // Cheap hover tooltip: the script's own tooltip text, which is
        // multi-line, rendered beside the bar.
        id: tip

        visible: hover.hovered && root.tooltipText.length > 0
        anchors.left: parent.right
        anchors.leftMargin: Tokens.spacing.small
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: tipText.implicitWidth + Tokens.padding.normal * 2
        implicitHeight: tipText.implicitHeight + Tokens.padding.small * 2
        radius: Tokens.rounding.small
        color: Colours.palette.m3surfaceContainer
        z: 100

        StyledText {
            id: tipText

            anchors.centerIn: parent
            text: root.tooltipText
            color: Colours.palette.m3onSurface
        }
    }

    HoverHandler {
        id: hover
    }

    Process {
        id: proc

        command: root.cmd
        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim();
                if (out.length === 0) {
                    root.hasData = false;
                    return;
                }
                try {
                    const data = JSON.parse(out);
                    // Drop the Nerd Font glyph or emoji the scripts prefix,
                    // but keep the units — a bare "37" reads worse than
                    // "37°". Icon-only scripts legitimately leave this empty.
                    root.label = (data.text ?? "").replace(/[^\x20-\x7E°%]/g, "").trim();
                    root.tooltipText = data.tooltip ?? "";
                    root.statusClass = data.class ?? "";
                    root.hasData = true;
                } catch (e) {
                    root.hasData = false;
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

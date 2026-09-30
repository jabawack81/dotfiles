pragma ComponentBehavior: Bound

// Local addition (not upstream caelestia) — see CHANGES-LOCAL.md.
//
// Power-state picker for the caffeine bar entry: hover the entry, click a
// state. The states and the switching itself belong to
// common/waybar/caffeine-toggle.sh, which is what the waybar bars and the
// Hyprland autostart use too — this is only a front end for it.
//
// Laid out to match the network popout: same width token, same margins and
// spacing, and the current state marked the way the connected network is,
// with colour and weight rather than a filled block.

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    id: root

    // Read straight from the state file caffeine-toggle.sh writes, so the
    // highlight follows changes made from anywhere (bar, keybind, CLI).
    property string currentState: ""

    readonly property var states: [
        {
            id: "normal",
            icon: "hourglass_empty",
            label: "Normal",
            detail: "Lock 10m, suspend 30m"
        },
        {
            id: "caffeine",
            icon: "coffee",
            label: "Caffeine",
            detail: "Screen stays awake"
        },
        {
            id: "remote",
            icon: "lan",
            label: "Remote",
            detail: "Locks fast, never suspends"
        },
        {
            id: "hibernate",
            icon: "mode_standby",
            label: "Hibernate",
            detail: "Locks fast, hibernates 5m"
        }
    ]

    // A Layout as a popout root needs an explicit width, exactly as the
    // network popout does — without one the hosting Loader centres it with
    // no width and it collapses to its minimum.
    spacing: Tokens.spacing.small
    width: Tokens.sizes.bar.networkWidth

    StyledText {
        Layout.topMargin: Tokens.padding.medium
        Layout.rightMargin: Tokens.padding.extraSmall
        text: "Power state"
        font: Tokens.font.body.builders.medium.build()
    }

    Repeater {
        model: root.states

        RowLayout {
            id: item

            required property var modelData
            readonly property bool active: root.currentState === modelData.id

            Layout.fillWidth: true
            Layout.rightMargin: Tokens.padding.extraSmall
            spacing: Tokens.spacing.small

            StateLayer {
                color: item.active ? Colours.palette.m3primary : Colours.palette.m3onSurface
                onClicked: switchProc.exec(["sh", "-c", `$HOME/.config/waybar_common/caffeine-toggle.sh ${item.modelData.id}`])
            }

            MaterialIcon {
                text: item.modelData.icon
                fill: item.active ? 1 : 0
                color: item.active ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            }

            ColumnLayout {
                Layout.leftMargin: Tokens.spacing.extraSmall
                Layout.rightMargin: Tokens.spacing.extraSmall
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: item.modelData.label
                    elide: Text.ElideRight
                    font: Tokens.font.body.builders.medium.weight(item.active ? Font.Medium : Font.Normal).build()
                    color: item.active ? Colours.palette.m3primary : Colours.palette.m3onSurface
                }

                StyledText {
                    Layout.fillWidth: true
                    text: item.modelData.detail
                    elide: Text.ElideRight
                    font: Tokens.font.body.builders.small.build()
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }

    Process {
        id: switchProc

        // Re-read the state once the switch has had a moment to land
        onExited: stateFile.reload()
    }

    FileView {
        id: stateFile

        printErrors: false
        path: `${Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"}/caffeine-state`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.currentState = text().trim()
    }
}

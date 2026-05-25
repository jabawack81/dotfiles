// Cyberpunk tech-terminal bar — Phase 1.
// Layout: [ WS workspaces ]  [ date ] [ HH:MM:SS ]    CPU ▓▓░ 42%  │  MEM ▓░ 8.2G
// Modules live in ./modules/. Theme constants in ./Theme.qml.
import Quickshell
import QtQuick
import "modules"

Scope {
    // On-screen display for volume/brightness — manages its own popup windows.
    Osd {}

    // Dashboard / control center popup — toggled by clicking the clock.
    Dashboard {}

    // Notification daemon + toasts (replaces dunst in quickshell mode).
    Notifications {}

    // Notification center history panel — toggled by the bell in the bar.
    NotificationCenter {}

    // Workspace overview — expose-style grid (Super+Tab via global shortcut).
    WorkspaceOverview {}

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Theme.barHeight
            color: Theme.bg

            // Thin neon line at the bottom as a tech accent
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Theme.barBorderWidth
                color: Theme.accent
            }

            // Left section: workspaces
            Item {
                id: leftSection
                anchors.left: parent.left
                anchors.leftMargin: Theme.modulePadding
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: leftRow.width

                Row {
                    id: leftRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 18

                    Workspaces { screen: modelData }
                    Media {}
                }
            }

            // Center section: clock
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: clock.implicitWidth

                Clock { id: clock }
            }

            // Right section: bedtime · caffeine · network · audio · temps · stats · tray
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.modulePadding
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 14

                Bell {}
                Bedtime {}
                Caffeine {}
                Network {}
                Audio {}
                Temperatures {}
                SystemStats {}
                Tray {}
                PowerMenu {}
            }
        }
    }
}

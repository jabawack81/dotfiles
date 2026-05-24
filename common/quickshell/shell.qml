// Cyberpunk tech-terminal bar — Phase 1.
// Layout: [ WS workspaces ]  [ date ] [ HH:MM:SS ]    CPU ▓▓░ 42%  │  MEM ▓░ 8.2G
// Modules live in ./modules/. Theme constants in ./Theme.qml.
import Quickshell
import QtQuick
import "modules"

Scope {
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
                width: childrenRect.width

                Workspaces { screen: modelData }
            }

            // Center section: clock
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: clock.implicitWidth

                Clock { id: clock }
            }

            // Right section: network + audio + temps + system stats
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.modulePadding
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 14

                Network {}
                Audio {}
                Temperatures {}
                SystemStats {}
            }
        }
    }
}

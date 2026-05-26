// Cyberpunk tech-terminal bar.
// Layout: [ WS ] media · · · clock · · · clip bell bedtime caffeine net audio temps stats tray power
// Design tokens live in Commons/ (Color, Style, Util, Globals); reusable UI
// in Ui/; feature modules in modules/.
import Quickshell
import QtQuick
import qs.Commons
import "modules"

Scope {
    // On-screen display for volume/brightness — manages its own popup windows.
    Osd {}

    // Notification daemon + toasts (replaces dunst in quickshell mode).
    Notifications {}

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

            implicitHeight: Style.barHeight
            color: Color.bar.background

            // Thin neon line at the bottom as a tech accent
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Style.barBorderWidth
                color: Color.bar.border
            }

            // Left section: workspaces + media
            Item {
                id: leftSection
                anchors.left: parent.left
                anchors.leftMargin: Style.modulePadding
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

            // Right section: clip · bell · bedtime · caffeine · network · audio · temps · stats · tray · power
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Style.modulePadding
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 14

                Clip {}
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

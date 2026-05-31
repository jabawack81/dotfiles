// Cyberpunk neon-glow bar — three floating, rounded, glowing islands
// (left / center / right) over the desktop, matching the omni-menu card look.
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

    // Omni menu — command palette (Super+Space via global shortcut).
    Omni {}

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors { top: true; left: true; right: true }
            implicitHeight: Style.barHeight + 12   // floating gap above + below
            color: "transparent"

            // A floating, rounded, glowing-bordered island. Content goes inside
            // a centered Row; the island sizes to it.
            component Island: Rectangle {
                default property alias islandData: inner.data
                property int hpad: 14
                implicitWidth: inner.implicitWidth + hpad * 2
                height: Style.barHeight
                radius: Style.cornerRadius
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Color.surfaceRaised }
                    GradientStop { position: 1.0; color: Color.surfaceDeep }
                }
                border.color: Color.accent
                border.width: 1

                // Layered outer glow (two concentric fading rings).
                Rectangle {
                    anchors.fill: parent; anchors.margins: -2; z: -1
                    radius: parent.radius + 2; color: "transparent"
                    border.color: Color.accent; border.width: 2; opacity: 0.16
                }
                Rectangle {
                    anchors.fill: parent; anchors.margins: -5; z: -2
                    radius: parent.radius + 5; color: "transparent"
                    border.color: Color.accent; border.width: 3; opacity: 0.07
                }

                Row {
                    id: inner
                    anchors.centerIn: parent
                    spacing: 16
                }
            }

            // Left island: workspaces + media
            Island {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                Workspaces { screen: bar.modelData }
                Media {}
            }

            // Center island: clock
            Island {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                Clock {}
            }

            // Right island: status cluster
            Island {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

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

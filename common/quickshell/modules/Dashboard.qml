// Dashboard / control center — opens below the clock when Globals.dashboardOpen.
// Sections: header clock, month calendar, system summary, power-state toggle.
// Cyberpunk styled: black panel, cyan borders, bracket section headers.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../"

Scope {
    id: scope

    LazyLoader {
        active: Globals.dashboardOpen

        component: Variants {
            // Show on the focused screen only — pick the first screen for simplicity.
            model: Quickshell.screens.slice(0, 1)

            PanelWindow {
                id: dashWindow
                required property var modelData
                screen: modelData

                anchors.top: true
                margins.top: Theme.barHeight + 6
                implicitWidth: 380
                implicitHeight: content.implicitHeight + 24
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

                // Close when clicking anywhere outside this window
                HyprlandFocusGrab {
                    active: true
                    windows: [dashWindow]
                    onCleared: Globals.dashboardOpen = false
                }

                Rectangle {
                    id: panel
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    width: 360
                    height: content.implicitHeight + 24
                    color: Theme.bgPanel
                    border.color: Theme.accent
                    border.width: 1

                    // Swallow clicks inside the panel so they don't close it
                    MouseArea { anchors.fill: parent }

                    Column {
                        id: content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 14

                        // === Header: full date + live time ===
                        Column {
                            spacing: 2
                            Text {
                                id: bigTime
                                text: "00:00:00"
                                color: Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 28
                                font.bold: true
                            }
                            Text {
                                id: bigDate
                                text: ""
                                color: Theme.textDim
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }
                            Timer {
                                interval: 1000
                                running: Globals.dashboardOpen
                                repeat: true
                                triggeredOnStart: true
                                onTriggered: {
                                    const d = new Date();
                                    bigTime.text = Qt.formatDateTime(d, "HH:mm:ss");
                                    bigDate.text = Qt.formatDateTime(d, "dddd · dd MMMM yyyy");
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.accentDim }

                        // === Calendar ===
                        Text {
                            text: "[ CALENDAR ]"
                            color: Theme.secondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                        }
                        CalendarGrid {}

                        Rectangle { width: parent.width; height: 1; color: Theme.accentDim }

                        // === System summary ===
                        Text {
                            text: "[ SYSTEM ]"
                            color: Theme.secondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                        }
                        DashSystem {}

                        Rectangle { width: parent.width; height: 1; color: Theme.accentDim }

                        // === Quick controls ===
                        Text {
                            text: "[ CONTROLS ]"
                            color: Theme.secondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                        }
                        DashControls {}
                    }
                }
            }
        }
    }
}

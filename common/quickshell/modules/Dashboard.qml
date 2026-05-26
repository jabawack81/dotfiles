// Dashboard / control center — opens below the clock when Globals.dashboardOpen.
// Sections: header clock, month calendar, system summary, power-state toggle.
// Cyberpunk styled: black panel, cyan borders, bracket section headers.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons

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
                margins.top: Style.barHeight + 6
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
                    color: Color.surface
                    border.color: Color.accent
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
                                color: Color.accent
                                font.family: Style.font.family
                                font.pixelSize: 28
                                font.bold: true
                            }
                            Text {
                                id: bigDate
                                text: ""
                                color: Color.textDim
                                font.family: Style.font.family
                                font.pixelSize: Style.font.base
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

                        Rectangle { width: parent.width; height: 1; color: Color.accentDim }

                        // === Calendar ===
                        Text {
                            text: "[ CALENDAR ]"
                            color: Color.secondary
                            font.family: Style.font.family
                            font.pixelSize: Style.font.small
                            font.bold: true
                        }
                        CalendarGrid {}

                        Rectangle { width: parent.width; height: 1; color: Color.accentDim }

                        // === System summary ===
                        Text {
                            text: "[ SYSTEM ]"
                            color: Color.secondary
                            font.family: Style.font.family
                            font.pixelSize: Style.font.small
                            font.bold: true
                        }
                        DashSystem {}

                        Rectangle { width: parent.width; height: 1; color: Color.accentDim }

                        // === Quick controls ===
                        Text {
                            text: "[ CONTROLS ]"
                            color: Color.secondary
                            font.family: Style.font.family
                            font.pixelSize: Style.font.small
                            font.bold: true
                        }
                        DashControls {}
                    }
                }
            }
        }
    }
}

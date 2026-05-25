// Notification center — history panel, opens top-right when the bell is clicked.
// Lists past notifications (newest first) with a clear-all action.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../"

Scope {
    id: scope

    LazyLoader {
        active: Globals.notificationCenterOpen

        component: Variants {
            model: Quickshell.screens.slice(0, 1)

            PanelWindow {
                id: ncWindow
                required property var modelData
                screen: modelData

                anchors.top: true
                anchors.right: true
                margins.top: Theme.barHeight + 6
                margins.right: 8
                implicitWidth: 380
                implicitHeight: 460
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

                // Close when clicking anywhere outside this window
                HyprlandFocusGrab {
                    active: true
                    windows: [ncWindow]
                    onCleared: Globals.notificationCenterOpen = false
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    width: 360
                    height: 440
                    color: Theme.bgPanel
                    border.color: Theme.accent
                    border.width: 1

                    MouseArea { anchors.fill: parent }  // swallow clicks inside

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        // Header row: title + clear-all
                        Row {
                            width: parent.width
                            Text {
                                text: "[ NOTIFICATIONS ]"
                                color: Theme.secondary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                width: parent.width - clearBtn.width
                            }
                            Text {
                                id: clearBtn
                                text: "CLEAR"
                                color: clearArea.containsMouse ? Theme.critical : Theme.textDim
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                MouseArea {
                                    id: clearArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: Globals.clearNotifications()
                                }
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.accentDim }

                        // Empty state
                        Text {
                            visible: Globals.notificationHistory.length === 0
                            text: "// no notifications"
                            color: Theme.textDim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        // Scrollable history list
                        ListView {
                            width: parent.width
                            height: parent.height - 60
                            clip: true
                            spacing: 8
                            visible: Globals.notificationHistory.length > 0
                            model: Globals.notificationHistory

                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                height: itemCol.implicitHeight + 16
                                color: Theme.bgInactive
                                border.width: 1
                                border.color: {
                                    if (modelData.urgency === 2) return Theme.critical;
                                    if (modelData.urgency === 0) return Theme.accentDim;
                                    return Theme.accent;
                                }

                                Column {
                                    id: itemCol
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 8
                                    spacing: 3

                                    Row {
                                        width: parent.width
                                        Text {
                                            text: "▶ " + modelData.appName
                                            color: parent.parent.parent.border.color
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSmall
                                            font.bold: true
                                            width: parent.width - 44
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: modelData.time
                                            color: Theme.textDim
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSmall
                                            horizontalAlignment: Text.AlignRight
                                            width: 44
                                        }
                                    }
                                    Text {
                                        width: parent.width
                                        text: modelData.summary
                                        color: Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.bold: true
                                        wrapMode: Text.WordWrap
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                    }
                                    Text {
                                        width: parent.width
                                        visible: modelData.body !== ""
                                        text: modelData.body
                                        color: Theme.textDim
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall
                                        wrapMode: Text.WordWrap
                                        elide: Text.ElideRight
                                        maximumLineCount: 3
                                        textFormat: Text.PlainText
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

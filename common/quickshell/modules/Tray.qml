// System tray — shows StatusNotifierItem icons for background apps
// (1Password, Discord, Slack, Telegram, etc.). Left-click activates,
// right-click opens a self-rendered cyberpunk menu from the app's DBusMenu.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import qs.Commons

Row {
    id: root
    spacing: 8
    anchors.verticalCenter: parent.verticalCenter

    Repeater {
        model: SystemTray.items

        delegate: MouseArea {
            id: trayItem
            required property var modelData
            property bool hovered: containsMouse

            implicitWidth: Style.font.base + 4
            implicitHeight: Style.font.base + 4
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.verticalCenter: parent.verticalCenter

            onClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                    modelData.activate();
                } else if (mouse.button === Qt.RightButton) {
                    if (modelData.hasMenu) {
                        menuPopup.visible = !menuPopup.visible;
                    } else {
                        modelData.secondaryActivate();
                    }
                }
            }

            Image {
                anchors.centerIn: parent
                // modelData.icon may be a freedesktop icon name or an
                // app-provided pixmap URL (image://qspixmap/...). Both work as
                // image sources directly; iconPath() only resolves the first.
                source: modelData.icon
                sourceSize.width: 20
                sourceSize.height: 20
                width: 18
                height: 18
                smooth: true
                opacity: parent.hovered ? 1.0 : 0.85

                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }
            }

            // Pulls the DBusMenu entries from the tray item's menu handle.
            QsMenuOpener {
                id: menuOpener
                menu: trayItem.modelData.menu
            }

            PopupWindow {
                id: menuPopup
                visible: false
                color: "transparent"
                implicitWidth: 200
                implicitHeight: menuColumn.implicitHeight + 2

                // Anchor directly to the icon: attach to its bottom edge and
                // expand down-and-left so the menu stays on-screen near the right.
                anchor.item: trayItem
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom | Edges.Left

                HyprlandFocusGrab {
                    active: menuPopup.visible
                    windows: [menuPopup]
                    onCleared: menuPopup.visible = false
                }

                Rectangle {
                    anchors.fill: parent
                    color: Color.surface
                    border.color: Color.accent
                    border.width: 1

                    Column {
                        id: menuColumn
                        anchors.fill: parent
                        anchors.margins: 1

                        Repeater {
                            model: menuOpener.children

                            delegate: Loader {
                                required property var modelData
                                width: menuColumn.width
                                sourceComponent: modelData.isSeparator ? sepComp : entryComp

                                Component {
                                    id: sepComp
                                    Rectangle {
                                        height: 1
                                        color: Color.accentDim
                                    }
                                }

                                Component {
                                    id: entryComp
                                    MouseArea {
                                        height: entryText.implicitHeight + 8
                                        hoverEnabled: true
                                        enabled: modelData.enabled
                                        onClicked: {
                                            modelData.triggered();
                                            menuPopup.visible = false;
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            color: parent.containsMouse ? Color.surfaceInactive : "transparent"
                                        }

                                        Text {
                                            id: entryText
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData.text
                                            color: !modelData.enabled ? Color.textDim
                                                 : (parent.containsMouse ? Color.highlight : Color.foreground)
                                            font.family: Style.font.family
                                            font.pixelSize: Style.font.small
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
}

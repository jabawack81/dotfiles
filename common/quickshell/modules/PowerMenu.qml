// Power button — opens a self-rendered cyberpunk dropdown matching the tray menu.
// Actions mirror the old wlogout layout: lock, suspend, logout, reboot,
// hibernate, shutdown. Each runs its command via Process.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../"

MouseArea {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    implicitHeight: powerIcon.implicitHeight
    implicitWidth: powerIcon.implicitWidth
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    onClicked: menuPopup.visible = !menuPopup.visible

    // Action list — label + shell command. Color marks destructive ones.
    property var actions: [
        { text: "Lock",      cmd: "hyprlock",            danger: false },
        { text: "Suspend",   cmd: "systemctl suspend",   danger: false },
        { text: "Hibernate", cmd: "systemctl hibernate", danger: false },
        { text: "Logout",    cmd: "hyprctl dispatch exit", danger: true },
        { text: "Reboot",    cmd: "systemctl reboot",    danger: true },
        { text: "Shutdown",  cmd: "systemctl poweroff",  danger: true },
    ]

    Process { id: actionProc }

    Text {
        id: powerIcon
        anchors.verticalCenter: parent.verticalCenter
        text: "⏻"
        color: root.containsMouse ? Theme.critical : Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 2
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    PopupWindow {
        id: menuPopup
        visible: false
        color: "transparent"
        implicitWidth: 160
        implicitHeight: menuColumn.implicitHeight + 2

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom | Edges.Left

        HyprlandFocusGrab {
            active: menuPopup.visible
            windows: [menuPopup]
            onCleared: menuPopup.visible = false
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.bgPanel
            border.color: Theme.accent
            border.width: 1

            Column {
                id: menuColumn
                anchors.fill: parent
                anchors.margins: 1

                Repeater {
                    model: root.actions

                    delegate: MouseArea {
                        required property var modelData
                        width: menuColumn.width
                        height: entryText.implicitHeight + 8
                        hoverEnabled: true
                        onClicked: {
                            actionProc.command = ["bash", "-c", modelData.cmd];
                            actionProc.running = true;
                            menuPopup.visible = false;
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: parent.containsMouse ? Theme.bgInactive : "transparent"
                        }

                        Text {
                            id: entryText
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.text
                            color: parent.containsMouse
                                 ? (modelData.danger ? Theme.critical : Theme.highlight)
                                 : (modelData.danger ? "#cc6666" : Theme.text)
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }
        }
    }
}

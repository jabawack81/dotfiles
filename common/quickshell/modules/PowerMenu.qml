// Power button — opens a cyberpunk dropdown (lock/suspend/hibernate/logout/
// reboot/shutdown). Uses the shared Ui.PopupCard for the popup chrome,
// anchoring, and click-away dismissal.
import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

MouseArea {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    implicitHeight: powerIcon.implicitHeight
    implicitWidth: powerIcon.implicitWidth
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    onClicked: menu.toggle()

    // Action list — label + shell command. danger marks destructive ones.
    property var actions: [
        { text: "Lock",      cmd: "hyprlock",              danger: false },
        { text: "Suspend",   cmd: "systemctl suspend",     danger: false },
        { text: "Hibernate", cmd: "systemctl hibernate",   danger: false },
        { text: "Logout",    cmd: "hyprctl dispatch exit", danger: true },
        { text: "Reboot",    cmd: "systemctl reboot",      danger: true },
        { text: "Shutdown",  cmd: "systemctl poweroff",    danger: true },
    ]

    Process { id: actionProc }

    Text {
        id: powerIcon
        anchors.verticalCenter: parent.verticalCenter
        text: "⏻"
        color: root.containsMouse ? Color.urgent : Color.accent
        font.family: Style.font.family
        font.pixelSize: Style.font.base + 2
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    PopupCard {
        id: menu
        anchorItem: root
        contentWidth: 160
        contentHeight: menuColumn.implicitHeight + Style.spacing.lg * 2

        Column {
            id: menuColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

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
                        menu.visible = false;
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: parent.containsMouse ? Color.surfaceInactive : "transparent"
                    }

                    Text {
                        id: entryText
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.text
                        color: parent.containsMouse
                             ? (modelData.danger ? Color.urgent : Color.highlight)
                             : (modelData.danger ? Color.urgentDim : Color.foreground)
                        font.family: Style.font.family
                        font.pixelSize: Style.font.small
                    }
                }
            }
        }
    }
}

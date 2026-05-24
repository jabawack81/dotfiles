// System tray — shows StatusNotifierItem icons for background apps
// (1Password, Discord, Slack, Telegram, etc.). Left-click activates,
// right-click opens the app's menu.
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../"

Row {
    id: root
    spacing: 8
    anchors.verticalCenter: parent.verticalCenter

    Repeater {
        model: SystemTray.items

        delegate: MouseArea {
            required property var modelData
            property bool hovered: containsMouse

            implicitWidth: Theme.fontSize + 4
            implicitHeight: Theme.fontSize + 4
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.verticalCenter: parent.verticalCenter

            onClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                    modelData.activate();
                } else if (mouse.button === Qt.RightButton) {
                    if (modelData.hasMenu) {
                        menuAnchor.open();
                    } else {
                        modelData.secondaryActivate();
                    }
                }
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: modelData.menu
                anchor.window: root.QsWindow.window
                anchor.rect.x: parent.x
                anchor.rect.y: parent.y + parent.height
                anchor.rect.width: parent.width
                anchor.rect.height: parent.height
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
        }
    }
}

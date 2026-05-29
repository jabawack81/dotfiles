// Reusable DBusMenu dropdown for a system tray item, rendered as a PopupCard.
// Used by both the inline tray icons and the overflow dropdown rows so the
// menu markup lives in one place. Set `item` (the SystemTrayItem) and
// `anchorItem` (the element to anchor under), then call toggle().
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

PopupCard {
    id: root
    required property var item

    padding: 1
    contentWidth: 210
    contentHeight: menuColumn.implicitHeight + 2

    // Pulls the DBusMenu entries from the tray item's menu handle.
    QsMenuOpener {
        id: opener
        menu: root.item ? root.item.menu : null
    }

    Column {
        id: menuColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Repeater {
            model: opener.children

            delegate: Loader {
                required property var modelData
                width: menuColumn.width
                sourceComponent: modelData.isSeparator ? sepComp : entryComp

                Component {
                    id: sepComp
                    Rectangle { height: 1; color: Color.accentDim }
                }

                Component {
                    id: entryComp
                    MouseArea {
                        height: entryText.implicitHeight + 8
                        hoverEnabled: true
                        enabled: modelData.enabled
                        onClicked: {
                            modelData.triggered();
                            root.visible = false;
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

// Stub quickshell config — just a minimal top bar so the launcher path works.
// Real cyberpunk theming comes later. Cyan border on black is the only styling.
import Quickshell
import QtQuick

Scope {
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

            implicitHeight: 30
            color: "#000000"

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: "#33ccff"
            }

            Text {
                anchors.centerIn: parent
                text: "QUICKSHELL — STUB · " + Qt.formatDateTime(new Date(), "hh:mm")
                color: "#33ccff"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: parent.text = "QUICKSHELL — STUB · " +
                        Qt.formatDateTime(new Date(), "hh:mm")
                }
            }
        }
    }
}

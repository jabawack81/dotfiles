// Notification bell — shows a count and toggles the notification center.
// Glyph changes when there's history; click opens/closes the center panel.
import QtQuick
import "../"

MouseArea {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth
    hoverEnabled: true
    onClicked: Globals.notificationCenterOpen = !Globals.notificationCenterOpen

    property int count: Globals.notificationHistory.length

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            text: Theme.bracketL
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
        Text {
            // Filled bell when there's history, hollow when empty
            text: root.count > 0 ? "󰂚 " + root.count : "󰂜"
            color: root.containsMouse ? Theme.highlight
                 : (root.count > 0 ? Theme.accent : Theme.textDim)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            text: Theme.bracketR
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}

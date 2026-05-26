// Notification bell — shows a count and toggles the notification center.
// Glyph changes when there's history; click opens/closes the center panel.
import QtQuick
import qs.Commons

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
            text: Style.bracketL
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.base
        }
        Text {
            // Filled bell when there's history, hollow when empty
            text: root.count > 0 ? "󰂚 " + root.count : "󰂜"
            color: root.containsMouse ? Color.highlight
                 : (root.count > 0 ? Color.accent : Color.textDim)
            font.family: Style.font.family
            font.pixelSize: Style.font.base
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            text: Style.bracketR
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.base
        }
    }
}

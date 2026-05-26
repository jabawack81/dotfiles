// Interactive bracketed bar pill: [ content ]
// Brackets are accent-colored; the content shows `baseColor`, switching to
// the hover highlight on mouse-over when `hoverHighlight` is set. It's a
// MouseArea, so callers attach onClicked / onWheel / acceptedButtons directly.
import QtQuick
import qs.Commons

MouseArea {
    id: root
    property string content: ""
    property color baseColor: Color.foreground
    property bool hoverHighlight: true
    property bool bold: false

    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    hoverEnabled: true

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
            text: root.content
            color: (root.hoverHighlight && root.containsMouse) ? Color.highlight : root.baseColor
            font.family: Style.font.family
            font.pixelSize: Style.font.base
            font.bold: root.bold
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

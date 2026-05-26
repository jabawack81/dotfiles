// Wraps a module in the tech-terminal bracket style: [ content ]
// Reusable shell for any module.
import QtQuick
import qs.Commons

Item {
    id: root
    property alias content: contentText.text
    property color contentColor: Color.foreground
    property color bracketColor: Color.accent
    property bool hovered: mouseArea.containsMouse
    signal clicked()
    signal rightClicked()

    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) root.rightClicked();
            else root.clicked();
        }
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            text: Style.bracketL
            color: root.bracketColor
            font.family: Style.font.family
            font.pixelSize: Style.font.base
        }
        Text {
            id: contentText
            color: root.hovered ? Color.highlight : root.contentColor
            font.family: Style.font.family
            font.pixelSize: Style.font.base

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }
        Text {
            text: Style.bracketR
            color: root.bracketColor
            font.family: Style.font.family
            font.pixelSize: Style.font.base
        }
    }
}

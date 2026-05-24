// Wraps a module in the tech-terminal bracket style: [ content ]
// Reusable shell for any module.
import QtQuick
import "../"

Item {
    id: root
    property alias content: contentText.text
    property color contentColor: Theme.text
    property color bracketColor: Theme.accent
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
            text: Theme.bracketL
            color: root.bracketColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
        Text {
            id: contentText
            color: root.hovered ? Theme.highlight : root.contentColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }
        Text {
            text: Theme.bracketR
            color: root.bracketColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}

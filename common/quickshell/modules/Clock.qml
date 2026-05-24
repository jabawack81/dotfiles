// Clock with cyberpunk bracket styling: [ HH:MM:SS ]
// Updates every second. Day/date on hover (tooltip-style via secondary text below).
import QtQuick
import Quickshell
import "../"

Row {
    id: root
    spacing: 6
    anchors.verticalCenter: parent.verticalCenter

    property string timeText: "00:00:00"
    property string dateText: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const d = new Date();
            root.timeText = Qt.formatDateTime(d, "HH:mm:ss");
            root.dateText = Qt.formatDateTime(d, "ddd · yyyy.MM.dd");
        }
    }

    Text {
        text: Theme.bracketL + root.dateText + Theme.bracketR
        color: Theme.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: Theme.bracketL
        color: Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: root.timeText
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: Theme.bracketR
        color: Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        anchors.verticalCenter: parent.verticalCenter
    }
}

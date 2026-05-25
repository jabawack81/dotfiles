// Clock with cyberpunk bracket styling: [ date ] [ HH:MM:SS ]
// Updates every second. Click toggles the dashboard.
import QtQuick
import Quickshell
import "../"

MouseArea {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    hoverEnabled: true
    onClicked: Globals.dashboardOpen = !Globals.dashboardOpen

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

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

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
            color: root.containsMouse ? Theme.highlight : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            text: Theme.bracketR
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

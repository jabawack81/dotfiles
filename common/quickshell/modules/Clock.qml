// Clock with cyberpunk bracket styling: [ date ] [ HH:MM:SS ]
// Updates every second. Click toggles the dashboard.
import QtQuick
import Quickshell
import qs.Commons

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
            text: Style.bracketL + root.dateText + Style.bracketR
            color: Color.textDim
            font.family: Style.font.family
            font.pixelSize: Style.font.small
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: Style.bracketL
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.base
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: root.timeText
            color: root.containsMouse ? Color.highlight : Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.base
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            text: Style.bracketR
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.base
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

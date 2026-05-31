// Clock with cyberpunk bracket styling: [ date ] [ HH:MM:SS ]
// Click opens the dashboard / control center in a PopupCard anchored under it
// (calendar, system summary, quick controls).
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

MouseArea {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    hoverEnabled: true
    onClicked: dash.toggle()

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

        BarText {
            small: true
            text: Style.bracketL + root.dateText + Style.bracketR
            color: Color.textDim
            anchors.verticalCenter: parent.verticalCenter
        }
        BarText {
            text: Style.bracketL
            color: Color.accent
            anchors.verticalCenter: parent.verticalCenter
        }
        BarText {
            text: root.timeText
            color: root.containsMouse || dash.visible ? Color.highlight : Color.foreground
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        BarText {
            text: Style.bracketR
            color: Color.accent
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // === Dashboard / control center ===
    PopupCard {
        id: dash
        anchorItem: root
        gravity: Edges.Bottom   // center under the (centered) clock
        contentWidth: 380
        contentHeight: dashCol.implicitHeight + Style.spacing.lg * 2

        Column {
            id: dashCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 14

            // Header: full date + live time
            Column {
                spacing: 2
                Text {
                    id: bigTime
                    text: "00:00:00"
                    color: Color.accent
                    font.family: Style.font.family
                    font.pixelSize: Style.font.big
                    font.bold: true
                }
                BarText {
                    id: bigDate
                    text: ""
                    color: Color.textDim
                }
                Timer {
                    interval: 1000
                    running: dash.visible
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: {
                        const d = new Date();
                        bigTime.text = Qt.formatDateTime(d, "HH:mm:ss");
                        bigDate.text = Qt.formatDateTime(d, "dddd · dd MMMM yyyy");
                    }
                }
            }

            Separator {}
            SectionHeader { title: "CALENDAR" }
            CalendarGrid {}

            Separator {}
            SectionHeader { title: "SYSTEM" }
            DashSystem { active: dash.visible }

            Separator {}
            SectionHeader { title: "CONTROLS" }
            DashControls { active: dash.visible }
        }
    }
}

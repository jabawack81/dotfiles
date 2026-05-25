// Month calendar grid with today highlighted. Pure JS date math — no Qt.labs.
// Monday-first week layout to match UK convention.
import QtQuick
import "../"

Column {
    id: root
    spacing: 4

    readonly property var now: new Date()
    readonly property int year: now.getFullYear()
    readonly property int month: now.getMonth()   // 0-based
    readonly property int today: now.getDate()

    // Build a flat array of cells: leading blanks + day numbers.
    readonly property var cells: {
        const first = new Date(year, month, 1);
        // JS getDay(): 0=Sun..6=Sat. Convert to Monday-first (0=Mon..6=Sun).
        let lead = (first.getDay() + 6) % 7;
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const out = [];
        for (let i = 0; i < lead; i++) out.push(0);
        for (let d = 1; d <= daysInMonth; d++) out.push(d);
        return out;
    }

    // Month/year label
    Text {
        text: Qt.formatDateTime(root.now, "MMMM yyyy")
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        font.bold: true
    }

    // Weekday header
    Row {
        spacing: 0
        Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
            delegate: Text {
                required property var modelData
                width: 44
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                color: Theme.accentDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }

    // Day grid — 7 columns
    Grid {
        columns: 7
        spacing: 0
        Repeater {
            model: root.cells
            delegate: Item {
                required property var modelData
                width: 44
                height: 24
                property bool isToday: modelData === root.today

                Rectangle {
                    anchors.centerIn: parent
                    width: 26
                    height: 20
                    visible: parent.isToday
                    color: "transparent"
                    border.color: Theme.accent
                    border.width: 1
                }
                Text {
                    anchors.centerIn: parent
                    text: parent.modelData > 0 ? String(parent.modelData) : ""
                    color: parent.isToday ? Theme.accent : Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: parent.isToday
                }
            }
        }
    }
}

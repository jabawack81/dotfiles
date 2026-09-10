// Notification bell — shows a count and opens the notification history in a
// PopupCard anchored under the icon (consistent with tray/power/clipboard).
// Left-click opens the history; right-click toggles Do Not Disturb.
import QtQuick
import qs.Commons
import qs.Ui

BarPill {
    id: root

    property int  count:  Globals.notificationHistory.length
    property bool dnd:    Globals.doNotDisturb
    property int  missed: Globals.missedCount

    // Struck-through bell while DND is on. Anything DND swallowed stays as an
    // amber "missed" badge — even after DND is switched off — until the center
    // is opened, so nothing slips past unseen. Otherwise filled when there's
    // history, hollow when empty.
    content: dnd        ? (missed > 0 ? "󰂛 " + missed : "󰂛")
           : missed > 0 ? "󰂚 " + missed
           : count > 0  ? "󰂚 " + count
           :              "󰂜"
    baseColor: center.visible ? Color.highlight
             : (dnd || missed > 0) ? Color.warning
             : count > 0 ? Color.accent
             :             Color.textDim

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
        if (mouse.button === Qt.RightButton) {
            Globals.toggleDoNotDisturb();
            return;
        }
        // Opening the center is the "I've seen them" signal.
        Globals.missedCount = 0;
        center.toggle();
    }

    ToolTip {
        anchorItem: root
        show: root.containsMouse && !center.visible
        contentWidth: 230
        contentHeight: tipCol.implicitHeight + Style.spacing.md * 2

        Column {
            id: tipCol
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 4
            BarText {
                small: true
                text: root.dnd ? "▶ DO NOT DISTURB" : "  notifications on"
                color: root.dnd ? Color.warning : Color.textDim
                font.bold: root.dnd
            }
            BarText {
                small: true
                visible: root.missed > 0
                text: "  " + root.missed + " missed since you last looked"
                color: Color.foreground
            }
            Item { width: 1; height: 2 }
            BarText { small: true; text: "left  · history";        color: Color.textDim }
            BarText { small: true; text: "right · toggle DND  (Super+Shift+N)"; color: Color.textDim }
        }
    }

    PopupCard {
        id: center
        anchorItem: root
        contentWidth: 380
        contentHeight: 460

        Column {
            anchors.fill: parent
            spacing: 10

            // Header: title + clear-all
            Row {
                width: parent.width
                SectionHeader {
                    title: "NOTIFICATIONS"
                    width: parent.width - clearBtn.width
                }
                BarText {
                    small: true
                    id: clearBtn
                    text: "CLEAR"
                    // Greyed out and inert when there's nothing to clear.
                    property bool hasItems: Globals.notificationHistory.length > 0
                    color: !hasItems ? Color.accentDim
                         : (clearArea.containsMouse ? Color.urgent : Color.textDim)
                    font.bold: true
                    MouseArea {
                        id: clearArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: clearBtn.hasItems
                        onClicked: Globals.clearNotifications()
                    }
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
            }

            Separator {}

            BarText {
                small: true
                visible: Globals.notificationHistory.length === 0
                text: "// no notifications"
                color: Color.textDim
            }

            ListView {
                width: parent.width
                height: parent.height - 60
                clip: true
                spacing: 8
                visible: Globals.notificationHistory.length > 0
                model: Globals.notificationHistory

                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: itemCol.implicitHeight + 16
                    color: Color.surfaceInactive
                    border.width: 1
                    radius: Style.cornerRadius
                    border.color: {
                        if (modelData.urgency === 2) return Color.urgent;
                        if (modelData.urgency === 0) return Color.accentDim;
                        return Color.accent;
                    }

                    Column {
                        id: itemCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 8
                        spacing: 3

                        Row {
                            width: parent.width
                            BarText {
                                small: true
                                text: "▶ " + modelData.appName
                                color: parent.parent.parent.border.color
                                font.bold: true
                                width: parent.width - 44
                                elide: Text.ElideRight
                            }
                            BarText {
                                small: true
                                text: modelData.time
                                color: Color.textDim
                                horizontalAlignment: Text.AlignRight
                                width: 44
                            }
                        }
                        BarText {
                            small: true
                            width: parent.width
                            text: modelData.summary
                            color: Color.foreground
                            font.bold: true
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            maximumLineCount: 2
                        }
                        BarText {
                            small: true
                            width: parent.width
                            visible: modelData.body !== ""
                            text: modelData.body
                            color: Color.textDim
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            maximumLineCount: 3
                            textFormat: Text.PlainText
                        }
                    }
                }
            }
        }
    }
}

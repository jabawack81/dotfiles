// Notification bell — shows a count and opens the notification history in a
// PopupCard anchored under the icon (consistent with tray/power/clipboard).
import QtQuick
import qs.Commons
import qs.Ui

BarPill {
    id: root
    // Filled bell when there's history, hollow when empty
    content: count > 0 ? "󰂚 " + count : "󰂜"
    baseColor: center.visible ? Color.highlight
             : (count > 0 ? Color.accent : Color.textDim)
    onClicked: center.toggle()

    property int count: Globals.notificationHistory.length

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
                Text {
                    id: clearBtn
                    text: "CLEAR"
                    // Greyed out and inert when there's nothing to clear.
                    property bool hasItems: Globals.notificationHistory.length > 0
                    color: !hasItems ? Color.accentDim
                         : (clearArea.containsMouse ? Color.urgent : Color.textDim)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.small
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
                            Text {
                                text: "▶ " + modelData.appName
                                color: parent.parent.parent.border.color
                                font.family: Style.font.family
                                font.pixelSize: Style.font.small
                                font.bold: true
                                width: parent.width - 44
                                elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.time
                                color: Color.textDim
                                font.family: Style.font.family
                                font.pixelSize: Style.font.small
                                horizontalAlignment: Text.AlignRight
                                width: 44
                            }
                        }
                        Text {
                            width: parent.width
                            text: modelData.summary
                            color: Color.foreground
                            font.family: Style.font.family
                            font.pixelSize: Style.font.small
                            font.bold: true
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            maximumLineCount: 2
                        }
                        Text {
                            width: parent.width
                            visible: modelData.body !== ""
                            text: modelData.body
                            color: Color.textDim
                            font.family: Style.font.family
                            font.pixelSize: Style.font.small
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

// Notification daemon + cyberpunk toast popups (replaces dunst).
// Registers as the org.freedesktop.Notifications server, stacks toasts
// top-right, urgency-colored border, auto-dismiss (critical stays until clicked).
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Commons

Scope {
    id: scope

    // Visible toast list — separate from the server's tracked list so toasts
    // can time out while the notification itself may persist server-side.
    property var popups: []

    NotificationServer {
        id: server
        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: function(notif) {
            notif.tracked = true;
            scope.popups = [...scope.popups, notif];
            Globals.pushNotification(notif);
        }
    }

    function remove(notif) {
        scope.popups = scope.popups.filter(n => n !== notif);
    }

    LazyLoader {
        active: scope.popups.length > 0

        component: Variants {
            model: Quickshell.screens.slice(0, 1)

            PanelWindow {
                required property var modelData
                screen: modelData

                anchors.top: true
                anchors.right: true
                margins.top: Style.barHeight + 6
                margins.right: 8
                implicitWidth: 360
                implicitHeight: Math.max(1, toastCol.implicitHeight)
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay

                Column {
                    id: toastCol
                    anchors.right: parent.right
                    anchors.top: parent.top
                    spacing: 8

                    Repeater {
                        model: scope.popups

                        delegate: Rectangle {
                            required property var modelData
                            width: 360
                            // Cap height as a safety net (summary/body are already
                            // line-limited + elided) so a toast can't grow tall.
                            height: Math.min(toastContent.implicitHeight + 20, 200)
                            color: Color.surface
                            border.width: 1
                            radius: Style.cornerRadius
                            border.color: {
                                // urgency: 0=low, 1=normal, 2=critical
                                if (modelData.urgency === 2) return Color.urgent;
                                if (modelData.urgency === 0) return Color.accentDim;
                                return Color.accent;
                            }

                            // Auto-dismiss timer (critical notifications stay)
                            Timer {
                                interval: 5000
                                running: modelData.urgency !== 2
                                onTriggered: scope.remove(modelData)
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: function(mouse) {
                                    if (mouse.button === Qt.RightButton) {
                                        modelData.dismiss();
                                    }
                                    scope.remove(modelData);
                                }
                            }

                            Column {
                                id: toastContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 10
                                spacing: 4

                                // Header: app name + close hint
                                Row {
                                    width: parent.width
                                    Text {
                                        text: "▶ " + (modelData.appName || "notify")
                                        color: parent.parent.parent.border.color
                                        font.family: Style.font.family
                                        font.pixelSize: Style.font.small
                                        font.bold: true
                                        width: parent.width - 16
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: "✕"
                                        color: Color.textDim
                                        font.family: Style.font.family
                                        font.pixelSize: Style.font.small
                                    }
                                }

                                Text {
                                    width: parent.width
                                    text: modelData.summary
                                    color: Color.foreground
                                    font.family: Style.font.family
                                    font.pixelSize: Style.font.base
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
                                    maximumLineCount: 4
                                    textFormat: Text.PlainText
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

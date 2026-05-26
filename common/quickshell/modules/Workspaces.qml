// Workspace indicator for Hyprland.
// Shows only workspaces assigned to this monitor (matched by name), sorted by id.
// Empty bar means no workspaces exist on this monitor yet — they appear as soon as
// you Super+1..0 or Super+N to create them.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons

Row {
    id: root

    // Set by shell.qml — used to filter workspaces to this monitor only.
    required property var screen

    spacing: 6
    anchors.verticalCenter: parent.verticalCenter

    // Reactive filtered+sorted list of workspaces on this monitor
    property var monitorWorkspaces: {
        const result = [];
        for (const ws of Hyprland.workspaces.values) {
            if (ws.monitor && ws.monitor.name === root.screen.name) {
                result.push(ws);
            }
        }
        result.sort((a, b) => a.id - b.id);
        return result;
    }

    Text {
        text: Style.bracketL + "WS" + Style.bracketR
        color: Color.textDim
        font.family: Style.font.family
        font.pixelSize: Style.font.base
        anchors.verticalCenter: parent.verticalCenter
    }

    Repeater {
        model: root.monitorWorkspaces
        delegate: MouseArea {
            required property var modelData
            property bool isActive: modelData.active
            property bool hasWindows: modelData.toplevels && modelData.toplevels.values.length > 0
            property bool hovered: containsMouse

            width: label.implicitWidth + 4
            height: label.implicitHeight
            hoverEnabled: true
            anchors.verticalCenter: parent.verticalCenter
            onClicked: Hyprland.dispatch("workspace " + modelData.id)

            Text {
                id: label
                anchors.centerIn: parent
                text: parent.isActive ? "●" + parent.modelData.id
                                      : String(parent.modelData.id)
                color: parent.isActive ? Color.accent
                                       : (parent.hovered ? Color.highlight
                                                         : (parent.hasWindows ? Color.foreground
                                                                              : Color.textDim))
                font.family: Style.font.family
                font.pixelSize: Style.font.base
                font.bold: parent.isActive

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }
            }
        }
    }
}

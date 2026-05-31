// A single workspace card for the overview: id + window list, click to switch.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

Rectangle {
    id: card
    required property var ws
    property bool isActive: ws.active
    // Keyboard cursor highlight (set by the overview); distinct from active.
    property bool selected: false

    // Resolve an app icon path from a Hyprland toplevel's window class.
    function iconFor(toplevel) {
        const cls = toplevel.lastIpcObject ? toplevel.lastIpcObject.class : "";
        if (!cls) return Quickshell.iconPath("application-x-executable");
        const entry = DesktopEntries.heuristicLookup(cls);
        if (entry && entry.icon)
            return Quickshell.iconPath(entry.icon, "application-x-executable");
        return Quickshell.iconPath(cls, "application-x-executable");
    }

    width: 240
    height: 140
    color: Color.surface
    // Keyboard cursor (magenta) takes visual precedence over the active
    // marker; which workspace is active is still shown by the ● inside.
    border.width: (selected || isActive) ? 2 : 1
    border.color: selected ? Color.highlight : (isActive ? Color.accent : Color.accentDim)
    radius: Style.cornerRadius

    MouseArea {
        anchors.fill: parent
        onClicked: {
            Hyprland.dispatch("workspace " + card.ws.id);
            Globals.overviewOpen = false;
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        BarText {
            small: true
            text: (card.isActive ? "● " : "") + "WS " + card.ws.id
            color: card.isActive ? Color.accent : Color.foreground
            font.bold: true
        }

        Rectangle { width: parent.width; height: 1; color: Color.accentDim }

        Column {
            width: parent.width
            spacing: 4
            Repeater {
                model: card.ws.toplevels ? card.ws.toplevels.values : []
                delegate: Row {
                    required property var modelData
                    width: parent.width
                    spacing: 6

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: card.iconFor(modelData)
                        sourceSize.width: 16
                        sourceSize.height: 16
                        width: 16
                        height: 16
                        smooth: true
                    }
                    BarText {
                        small: true
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 22
                        // Prefer Hyprland's live window title (e.g. "tmux"),
                        // fall back to class, then a generic label.
                        text: {
                            const ipc = modelData.lastIpcObject;
                            return (ipc && ipc.title) || (ipc && ipc.class) || "window";
                        }
                        color: Color.textDim
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }
            }
        }
    }
}

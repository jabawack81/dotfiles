// Clipboard history — bar icon + popup anchored under it.
// cliphist provides the store; entries are "<id>\t<preview>", re-copied through
// `cliphist decode | wl-copy`. Searchable; click-away closes via focus grab.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons

MouseArea {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth
    hoverEnabled: true
    onClicked: {
        if (!menuPopup.visible) { scope.filter = ""; root.refresh(); }
        menuPopup.visible = !menuPopup.visible;
    }

    QtObject {
        id: scope
        property var entries: []     // [{ raw, preview }]
        property string filter: ""
    }

    function filtered() {
        if (scope.filter === "") return scope.entries;
        const f = scope.filter.toLowerCase();
        return scope.entries.filter(e => e.preview.toLowerCase().includes(f));
    }

    function refresh() { listProc.running = true; }

    function shellQuote(s) { return "'" + String(s).replace(/'/g, "'\\''") + "'"; }

    function copyEntry(raw) {
        copyProc.command = ["bash", "-c",
            "printf '%s' " + shellQuote(raw) + " | cliphist decode | wl-copy"];
        copyProc.running = true;
        menuPopup.visible = false;
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of this.text.split("\n")) {
                    if (!line.trim()) continue;
                    const tab = line.indexOf("\t");
                    out.push({ raw: line, preview: tab >= 0 ? line.slice(tab + 1) : line });
                }
                scope.entries = out;
            }
        }
    }
    Process { id: copyProc }
    Process {
        id: wipeProc
        command: ["cliphist", "wipe"]
        onExited: root.refresh()
    }

    // === Bar icon ===
    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            text: Style.bracketL
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.base
        }
        Text {
            text: "󰅍"
            color: root.containsMouse || menuPopup.visible ? Color.highlight : Color.textDim
            font.family: Style.font.family
            font.pixelSize: Style.font.base
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            text: Style.bracketR
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.base
        }
    }

    // === Popup, anchored under the icon ===
    PopupWindow {
        id: menuPopup
        visible: false
        color: "transparent"
        implicitWidth: 420
        implicitHeight: 460

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom | Edges.Left

        // Native xdg-popup grab: takes keyboard focus (for search) and is
        // dismissed by the compositor when clicking outside → onClosed.
        grabFocus: true
        onClosed: menuPopup.visible = false

        Rectangle {
            anchors.fill: parent
            color: Color.surface
            border.color: Color.accent
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                // Header + wipe
                Row {
                    width: parent.width
                    Text {
                        text: "[ CLIPBOARD ]"
                        color: Color.secondary
                        font.family: Style.font.family
                        font.pixelSize: Style.font.small
                        font.bold: true
                        width: parent.width - wipeBtn.width
                    }
                    Text {
                        id: wipeBtn
                        text: "WIPE"
                        color: wipeArea.containsMouse ? Color.urgent : Color.textDim
                        font.family: Style.font.family
                        font.pixelSize: Style.font.small
                        font.bold: true
                        MouseArea {
                            id: wipeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: wipeProc.running = true
                        }
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }

                // Search box
                Rectangle {
                    width: parent.width
                    height: 28
                    color: Color.background
                    border.color: Color.accentDim
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        spacing: 6
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "❯"
                            color: Color.accent
                            font.family: Style.font.family
                            font.pixelSize: Style.font.small
                        }
                        TextInput {
                            id: searchInput
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 30
                            color: Color.foreground
                            font.family: Style.font.family
                            font.pixelSize: Style.font.small
                            focus: true
                            onTextChanged: scope.filter = text
                            Connections {
                                target: menuPopup
                                function onVisibleChanged() {
                                    if (menuPopup.visible) searchInput.text = "";
                                }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Color.accentDim }

                Text {
                    visible: root.filtered().length === 0
                    text: "// clipboard empty"
                    color: Color.textDim
                    font.family: Style.font.family
                    font.pixelSize: Style.font.small
                }

                ListView {
                    width: parent.width
                    height: parent.height - 100
                    clip: true
                    spacing: 4
                    model: root.filtered()

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 28
                        color: clipArea.containsMouse ? Color.surfaceInactive : Color.background
                        border.color: Color.accentDim
                        border.width: 1

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: Text.AlignVCenter
                            text: modelData.preview
                            color: clipArea.containsMouse ? Color.highlight : Color.foreground
                            font.family: Style.font.family
                            font.pixelSize: Style.font.small
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                        MouseArea {
                            id: clipArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.copyEntry(modelData.raw)
                        }
                    }
                }
            }
        }
    }
}

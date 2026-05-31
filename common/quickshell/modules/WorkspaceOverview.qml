// Workspace overview — expose-style grid of all workspaces and their windows.
// Triggered by a Hyprland global shortcut (Super+Tab). Click a workspace to
// switch, click a window to focus it. Esc / click-away / outside click closes.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

Scope {
    id: scope

    // All workspace ids ordered left-monitor-first then by id — the order
    // Tab cycles through.
    function orderedIds() {
        const ws = [...Hyprland.workspaces.values];
        ws.sort((a, b) => {
            const ax = a.monitor ? a.monitor.x : 0;
            const bx = b.monitor ? b.monitor.x : 0;
            return ax !== bx ? ax - bx : a.id - b.id;
        });
        return ws.map(w => w.id);
    }

    function moveSelection(delta) {
        const ids = orderedIds();
        if (!ids.length) return;
        const cur = ids.indexOf(Globals.overviewSelectedId);
        const next = cur < 0 ? 0 : (cur + delta + ids.length) % ids.length;
        Globals.overviewSelectedId = ids[next];
    }

    function activateSelection() {
        if (Globals.overviewSelectedId > 0)
            Hyprland.dispatch("workspace " + Globals.overviewSelectedId);
        Globals.overviewOpen = false;
    }

    // Hyprland binds to this via: bind = SUPER, TAB, global, quickshell:overview
    GlobalShortcut {
        appid: "quickshell"
        name: "overview"
        onPressed: {
            if (!Globals.overviewOpen)
                Globals.overviewSelectedId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;
            Globals.overviewOpen = !Globals.overviewOpen;
        }
    }

    LazyLoader {
        active: Globals.overviewOpen

        component: Variants {
            // One overview per monitor — each shows only that monitor's workspaces.
            model: Quickshell.screens

            PanelWindow {
                id: overviewWindow
                required property var modelData
                screen: modelData

                anchors.top: true
                anchors.bottom: true
                anchors.left: true
                anchors.right: true
                color: "#cc000000"   // dim full-screen backdrop
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

                // Keyboard navigation. The Wayland layer holds keyboard focus,
                // but Qt only routes key events to a focused scene item — so the
                // handlers live on a focused Item that grabs focus on load.
                // Tab/Backtab need dedicated handlers because Qt's focus system
                // swallows them before Keys.onPressed.
                Item {
                    anchors.fill: parent
                    focus: true
                    Component.onCompleted: forceActiveFocus()

                    Keys.onTabPressed: scope.moveSelection(1)
                    Keys.onBacktabPressed: scope.moveSelection(-1)
                    Keys.onPressed: function(event) {
                        switch (event.key) {
                            case Qt.Key_Escape:
                                Globals.overviewOpen = false; break;
                            case Qt.Key_Return:
                            case Qt.Key_Enter:
                            case Qt.Key_Space:
                                scope.activateSelection(); break;
                            case Qt.Key_Right:
                            case Qt.Key_Down:
                            case Qt.Key_L:
                            case Qt.Key_J:
                                scope.moveSelection(1); break;
                            case Qt.Key_Left:
                            case Qt.Key_Up:
                            case Qt.Key_H:
                            case Qt.Key_K:
                                scope.moveSelection(-1); break;
                            default:
                                if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                                    Hyprland.dispatch("workspace " + (event.key - Qt.Key_0));
                                    Globals.overviewOpen = false;
                                } else {
                                    return;
                                }
                        }
                        event.accepted = true;
                    }
                }

                // Click backdrop to close
                MouseArea {
                    anchors.fill: parent
                    onClicked: Globals.overviewOpen = false
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 16

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "[ WORKSPACES · " + overviewWindow.modelData.name + " ]"
                        color: Color.accent
                        font.family: Style.font.family
                        font.pixelSize: Style.font.base + 2
                        font.bold: true
                    }

                    // This monitor's workspaces only, sorted by id, in a 3-wide grid
                    Grid {
                        anchors.horizontalCenter: parent.horizontalCenter
                        columns: 3
                        spacing: 14

                        Repeater {
                            model: {
                                const all = [...Hyprland.workspaces.values];
                                const mine = all.filter(w => w.monitor && w.monitor.name === overviewWindow.modelData.name);
                                mine.sort((a, b) => a.id - b.id);
                                return mine;
                            }
                            delegate: WsCard {
                                required property var modelData
                                ws: modelData
                                selected: modelData.id === Globals.overviewSelectedId
                            }
                        }
                    }

                    BarText {
                        small: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "// tab·arrows move · enter select · 1-9 jump · esc close"
                        color: Color.textDim
                    }
                }
            }
        }
    }
}

// Workspace overview — expose-style grid of all workspaces and their windows.
// Triggered by a Hyprland global shortcut (Super+Tab). Click a workspace to
// switch, click a window to focus it. Esc / click-away / outside click closes.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../"

Scope {
    id: scope

    // Hyprland binds to this via: bind = SUPER, TAB, global, quickshell:overview
    GlobalShortcut {
        appid: "quickshell"
        name: "overview"
        onPressed: Globals.overviewOpen = !Globals.overviewOpen
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

                // Esc closes
                Keys.onEscapePressed: Globals.overviewOpen = false

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
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
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
                            }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "// click a workspace to switch · esc to close"
                        color: Theme.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }
        }
    }
}
